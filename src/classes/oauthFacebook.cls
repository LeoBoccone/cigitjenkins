public class oauthFacebook extends oauthBase{
    public String message {get; set;}
    PageReference authPage;
    public String name {get; set;}
	public Boolean info {get; set;}
	public String me {get; set;}
	
	public PageReference finalAuth(){
        String message = ApexPages.currentPage().getParameters().get('code');
        System.debug('code: '+message);
        String end_point = 'https://graph.facebook.com/oauth/access_token?client_id=1591429937789030&redirect_uri=https://c.na24.visual.force.com/apex/oauthTest&client_secret=af029434a4f97474a5a205adcd2a7c2e&code='+message;
        Request = new HttpRequest();
        Request.setEndpoint(end_point);
        Request.setMethod('GET');
        Http http = new Http();
        Response = http.send(Request);
        Request = new HttpRequest();
       if(!String.isBlank(message)){
       		Token = Response.getBody().substring(Response.getBody().indexOf('=')+1, Response.getBody().indexOf('&'));
        	String end_point_access_token = 'https://graph.facebook.com/me?access_token='+ Token;
	        Request.setEndpoint(end_point_access_token);
	        Request.setMethod('GET');
	        Http http2 = new Http();
	        Response = http2.send(Request);
	        me = Response.getBody();
            message = Response.getBody();
            info = true;
    	}
        
    	return null;
    }
    
    public PageReference doAuthorization(){
        String authURL = getUnauthorizedReqToken();
        authPage=new PageReference(authURL);
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
}