import azure.functions as func
import logging
import os
import requests
import json
import re 
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import json
import base64
import statsmodels.api as sm
import sklearn
import io

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

def get_access_token():
    tenant_id = os.environ["BC_TENANT_ID"]
    client_id = os.environ["BC_CLIENT_ID"]
    client_secret = os.environ["BC_CLIENT_SECRET"]
    scope = "https://api.businesscentral.dynamics.com/.default"

    url = f"https://login.microsoftonline.com/{tenant_id}/oauth2/v2.0/token"
    data = {
        "grant_type": "client_credentials",
        "client_id": client_id,
        "client_secret": client_secret,
        "scope": scope
    }

    response = requests.post(url, data=data)
    response.raise_for_status()
    return response.json()["access_token"]

def get_bc_data(relative_url, environment):
    if not environment:
        raise ValueError("Environment is required (e.g., 'sandbox' or 'production')")
        
    tenant_id = os.environ["BC_TENANT_ID"]
    
    token = get_access_token()
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/json"
    }

    base_url = f"https://api.businesscentral.dynamics.com/v2.0/{tenant_id}/{environment}/api"
    full_url = f"{base_url}/{relative_url}"
    
    try:
        response = requests.get(full_url, headers=headers)
        response.raise_for_status()
        
        # Check content type to determine response format
        content_type = response.headers.get('content-type', '').lower()
        
        if 'application/json' in content_type:
            # Return JSON data
            return response.json()
        else:
            # For other content types, return as text
            return {"text_data": response.text}
            
    except requests.exceptions.HTTPError as e:
        # Capture detailed error information
        error_details = {
            "error": True,
            "status_code": response.status_code,
            "url": full_url,
            "headers": dict(response.headers),
            "response_body": response.text,
            "error_message": str(e)
        }
        
        # Try to parse JSON error response if available
        try:
            error_details["error_json"] = response.json()
        except:
            pass
            
        raise Exception(f"Business Central API Error: {json.dumps(error_details, indent=2)}")
    except requests.exceptions.RequestException as e:
        raise Exception(f"Request Error: {str(e)}")

def get_safe_globals():
    import builtins
    
    # List of built-in functions that should NOT be allowed
    restricted_builtins = {
        "open", "eval", "exec", "compile", "input", "globals", "locals",
        "vars", "delattr", "setattr", "getattr", "__import__", "exit", "quit"
    }
    
    # Build a safe version of __builtins__
    safe_builtin_dict = {
        k: getattr(builtins, k)
        for k in dir(builtins)
        if not k.startswith("__") and k not in restricted_builtins
    }
    
    return {
        "get_bc_data": get_bc_data,
        "pd": pd,
        "np": np,
        "plt": plt,
        "io": io,
        "json": json,
        "base64": base64,
        "sm": sm,
        "sklearn": sklearn,
        "__builtins__": safe_builtin_dict
    }
    

@app.route(route="execute", methods=["POST"])
def main(req: func.HttpRequest) -> func.HttpResponse:
    import traceback
    logging.info("Python BC Function triggered")

    try:
        body = req.get_json()
        user_code = body.get("code")

        # Improved security check using regex word boundaries
        restricted_keywords = ["os", "sys", "subprocess", "open", "eval", "exec", "importlib"]
        pattern = r'\b(' + '|'.join(restricted_keywords) + r')\b'
        match = re.search(pattern, user_code)
        if match:
            # Return plain text error instead of JSON
            return func.HttpResponse(
                f"Unsafe code detected — usage of '{match.group()}' is not allowed.",
                status_code=400,
                mimetype="text/plain"
            )

        # Prepare safe execution environment
        safe_globals = get_safe_globals()

        safe_locals = {}
        exec(user_code, safe_globals, safe_locals)
        logging.info(f"Executed code: {user_code}")
        
        output = safe_locals.get("output")
        logging.info(output)
        
        if output is None:
            # Return plain text error instead of JSON
            return func.HttpResponse(
                "No 'output' variable returned from the script.",
                status_code=400,
                mimetype="text/plain"
            )
        
        # Ensure data is always in text format to avoid serialization issues
        if isinstance(output, dict) and "data" in output:
            # Convert data to string format to avoid serialization errors
            output["data"] = str(output["data"])
        
        # Now we can safely convert to JSON
        return func.HttpResponse(
            json.dumps(output),
            status_code=200,
            mimetype="application/json"
        )

    except Exception as e:
        tb = traceback.format_exc()
        error_message = f"Python Error: {str(e)}\n{tb}"
        
        logging.error(error_message)
        
        # Return the error as plain text with a 400 status code
        return func.HttpResponse(
            error_message,
            status_code=400,
            mimetype="text/plain"
        )