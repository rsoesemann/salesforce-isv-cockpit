public with sharing class OpenAiCompletions {

    public static Response response(String jsonString) {
        return (Response) JSON.deserialize(jsonString, Response.class);
    }

    // INNER

    public class Request {
        public String model;
        public String prompt;
        public Integer max_tokens = 200;

        public Request model(String value) {
            model = value;
            return this;
        }

        public Request prompt(String value) {
            prompt = value;
            return this;
        }

        public String asJson() {
            return JSON.serialize(this);
        }
    }


    public class Response {
        public List<Choice> choices = new List<Choice>();

        public Response withChoice(String text) {
            Choice choice = new Choice();
            choice.text = text;
            choices.add(choice);
            return this;
        }
    }


    public class Choice {
        public String text;
        public Integer index;
        public String finish_reason;
    }
}