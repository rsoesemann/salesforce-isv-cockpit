@IsTest
public class HttpMock implements HttpCalloutMock {

    private Map<String, Map<String, Object>> responses = new Map<String, Map<String, Object>>();
    
    private static final String CONDITION = '#';


    // PUBLIC

    public HttpMock get(String url, Object body, Integer statusCode) {
        return mock('GET', url, body, statusCode);
    }


    public HttpMock get(String url, Object body) {
        return get(url, body, 200);
    }


    public HttpMock post(String url, Object body, Integer statusCode) {
        return mock('POST', url, body, statusCode);
    }


    public HttpMock post(String url, Object body) {
        return post(url, body, 200);
    }


    public HttpMock put(String url, Object body, Integer statusCode) {
        return mock('PUT', url, body, statusCode);
    }


    public HttpMock put(String url, Object body) {
        return put(url, body, 200);
    }


    public void mock() {
        Test.setMock(HttpCalloutMock.class, this);
    }


    public static Object object(SObjectType type, Map<String, Object> properties) {
        Map<String, Object> result = new Map<String, Object>{
            'attributes' => new Map<String, Object>{
                'type' => '' + type,
                'url' => '/services/data/v25.0/sobjects/' + type + '/' + new Random().id(type)
            }
        };
        result.putAll(properties);
        return JSON.deserialize( JSON.serialize(result), System.Type.forName('' + type));

    }

    // implements HttpCalloutMock

    public HttpResponse respond(HttpRequest request) {
        HttpResponse result = badRequest();

        Object response = mockedResponse(request);
        if(response != null) {
            if(response instanceof Exception) {
                throw (Exception) response;
            }

            result = (HttpResponse) response;
        }

        return result;
    }


    // PRIVATE

    private HttpMock mock(String method, String url, Object body, Integer statusCode) {
        if(!responses.containsKey(method)) {
            responses.put(method, new Map<String, Object>());
        }
        responses.get(method).put(url, asResponse(body, statusCode));

        return this;
    }


    private Object asResponse(Object body, Integer statusCode) {
        HttpResponse result = new HttpResponse();
        result.setStatusCode(statusCode);

        if(body instanceof Exception) {
            return body;
        }
        else if(body instanceof Blob) {
            result.setHeader('Content-Type', 'application/octet-stream');
            result.setBodyAsBlob((Blob) body);
        }
        else {
            result.setHeader('Content-Type', 'application/json');
            result.setBody( JSON.serialize(body) );
        }
        
        return result;
    }


    private Object mockedResponse(HttpRequest request) {
        Object result = null;

        String method = request.getMethod();
        if(responses.containsKey(method)) {
            for(String mock : responses.get(method).keySet()) {

                if(matches(request, mock)) {
                    result = responses.get(method).remove(mock);
                    break;
                }
            }
        }
        
        return result;
    }

    
    private Boolean matches(HttpRequest request, String candidate) {
        String url = new Url(request.getEndpoint()).getPath();
        String bodyCondition = candidate.substringAfter(CONDITION);
        candidate = candidate.removeEnd(CONDITION + bodyCondition);

        Boolean urlMatch = (candidate.indexOfDifference(url) == -1);
        Boolean bodyMatch = (bodyCondition == null || request.getBody().contains(bodyCondition));

        return (urlMatch && bodyMatch);
    }


    private HttpResponse badRequest() {
        HttpResponse result = new HttpResponse();
        result.setStatusCode(500);
        result.setStatus('Invalid Request');
        result.setBody('{}');
        return result;
    }


    private HttpResponse asJsonResponse(Object body, Integer statusCode) {
        HttpResponse result = new HttpResponse();
        result.setHeader('Content-Type', 'application/json');
        result.setStatusCode(statusCode);
        result.setBody( JSON.serialize(body) );
        return result;
    }
}