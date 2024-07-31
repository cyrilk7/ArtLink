from flask import request
import functions_framework
from api_config import app, db

import endpoints

@functions_framework.http
def hello_http(request):
    with app.request_context(request.environ):
        response = app.full_dispatch_request()
        return response

if __name__ == "__main__":
    app.run(debug=True)