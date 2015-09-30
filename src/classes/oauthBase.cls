public abstract class oauthBase {

	public Enum Methods {GET, POST, PUT, REST_DELETE}
	protected  HttpRequest Request;
	protected  HTTPResponse Response;
	protected  String Token;

	public static String getRandomNonce(){
       String allChars='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
       String nonce='';
       for(integer cnt=0; cnt<=9;cnt++)   {
           Integer i = 1+Math.Round(700.0*Math.random()/26);
           if (i<=26)
           {
              i--;
              String newStr=allChars.substring(i,i+1);
              nonce=nonce+newStr;
          }else{
            cnt--;
          }
      }
      return nonce;
    }

    public String basicAuthCallout(String endPoint, Map<String,String> header, String body,String method){
        Request = new HttpRequest();
        endpoint=endpoint+'?'+body;
        Request.setEndpoint(endPoint);
        Request.setMethod(method);
        Http http = new Http();
        Response  = http.send(Request);
        return Response.getBody();
    }
}