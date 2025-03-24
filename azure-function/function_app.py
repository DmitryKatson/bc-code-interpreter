import azure.functions as func
import logging
import os
import requests
import json

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

    base_url = f"https://api.businesscentral.dynamics.com/v2.0/{tenant_id}/{environment}/api/v2.0"
    response = requests.get(f"{base_url}/{relative_url}", headers=headers)
    response.raise_for_status()
    return response.json()

@app.route(route="main")
def main(req: func.HttpRequest) -> func.HttpResponse:
    import traceback
    logging.info("Python BC Function triggered")

    try:
        body = req.get_json()
        user_code = body.get("code")

        # Basic security check
        restricted_keywords = ["os", "sys", "subprocess", "open", "eval", "exec", "importlib"]
        if any(kw in user_code for kw in restricted_keywords):
            return func.HttpResponse(
                "Error: Unsafe code detected (restricted keywords used).",
                status_code=400,
                mimetype="text/plain"
            )

        # Prepare safe execution environment
        safe_globals = {
            "get_bc_data": get_bc_data,
            "__builtins__": {
                "range": range,
                "len": len,
                "sum": sum,
                "min": min,
                "max": max,
                "sorted": sorted,
                "dict": dict,
                "list": list,
                "str": str,
                "int": int,
                "float": float,
                "bool": bool,
                "abs": abs,
                "round": round,
                "map": map,
                "filter": filter
            }
        }

        safe_locals = {}
        exec(user_code, safe_globals, safe_locals)

        result = safe_locals.get("output")
        if result is None:
            return func.HttpResponse(
                "Error: No 'output' variable returned from the script.",
                status_code=400,
                mimetype="text/plain"
            )

        return func.HttpResponse(
            json.dumps({ "result": result }),
            status_code=200,
            mimetype="application/json"
        )

    except Exception as e:
        # Include traceback for easier debugging
        tb = traceback.format_exc()
        return func.HttpResponse(
            f"Error during execution:\n{str(e)}\n\n{tb}",
            status_code=500,
            mimetype="text/plain"
        )