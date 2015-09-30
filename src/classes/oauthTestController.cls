public with sharing class oauthTestController {

    public String message {get; set;}
    PageReference authPage;
    public String name {get; set;}
	public Boolean info {get; set;}
	public String me {get; set;}

    public PageReference finalAuth(){
        String message = ApexPages.currentPage().getParameters().get('code');
        System.debug('code: '+message);
        String pepe = 'https://graph.facebook.com/oauth/access_token?client_id=1591429937789030&redirect_uri=https://c.na24.visual.force.com/apex/oauthTest&client_secret=af029434a4f97474a5a205adcd2a7c2e&code='+message;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(pepe);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        HttpRequest req2 = new HttpRequest();
        HTTPResponse res2;
       if(!String.isBlank(message)){
        	String get_me = 'https://graph.facebook.com/me?access_token='+res.getBody().substring(res.getBody().indexOf('=')+1, res.getBody().indexOf('&'));
	       	System.debug(res.getBody().substring(res.getBody().indexOf('=')+1, res.getBody().indexOf('&')));
	        req2.setEndpoint(get_me);
	        req2.setMethod('GET');
	        Http http2 = new Http();
	        res2 = http2.send(req2);
	        System.debug(res2.getBody());
	        me = res2.getBody();
            message = res2.getBody();
            info = true;
    }
        
    return null;
    }
    
    public PageReference doAuthorization(){
        String authURL = getUnauthorizedReqToken();
        authPage=new PageReference(authURL);
        System.debug('-----:'+authURL);
        authPage.setRedirect(true);
        return authPage;
    }
    
    //This method creates and returns a URL to get a temporary token
    public String getUnauthorizedReqToken(){
        String vf_url = 'https://c.na24.visual.force.com/apex/oauthTest';
        String state = getRandomNonce();
        String body='client_id=1591429937789030&redirect_uri='+vf_url+'&scope=email,user_status&state='+state;
        String retUrl='https://www.facebook.com/dialog/oauth?'+body;
        return retUrl;
    }

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

    public String basicAuthCallout(String endPoint,String header, String body,String method){
        HttpRequest req = new HttpRequest();
        endpoint=endpoint+'?'+body;
        req.setEndpoint(endPoint);
        req.setMethod(method);
        Http http = new Http();
        debugOnlyPurpose('REQ_BODY', endPoint);
        HTTPResponse res = http.send(req);
        return res.getBody();
    }

    private void debugOnlyPurpose(String message_to_display, String specific_output){
        System.debug('==========='+message_to_display+' : '+specific_output);
    }

}