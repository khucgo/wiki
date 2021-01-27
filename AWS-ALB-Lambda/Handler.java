package lambdademo;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;

import org.json.simple.JSONObject;
import org.json.simple.JSONValue;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

public class Handler {

  Gson gson = new GsonBuilder().setPrettyPrinting().create();

  public static JSONObject sampleResponse()
  {
    JSONObject obj = new JSONObject();
    obj.put("statusCode", new Integer(200));
    obj.put("statusDescription", "200 OK");
    obj.put("isBase64Encoded", false);
    obj.put("body", "It works!");

    return obj;
  }

  public JSONObject handleRequest(JSONObject event, Context context)
  {
    LambdaLogger logger = context.getLogger();
    // log execution details
    logger.log("ENVIRONMENT VARIABLES: " + gson.toJson(System.getenv()));
    logger.log("CONTEXT: " + gson.toJson(context));
    // process event
    logger.log("EVENT: " + gson.toJson(event));
    logger.log("EVENT TYPE: " + event.getClass().toString());

    JSONObject response = sampleResponse();
    logger.log("Response: " + JSONValue.toJSONString(response));

    return response;
  }
}
