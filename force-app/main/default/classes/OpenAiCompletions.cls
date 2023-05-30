public with sharing class OpenAiCompletions {

    public static Response response(String jsonString) {
        return (Response) JSON.deserialize(jsonString, Response.class);
    }

    // INNER

    // PMD Json Wrapper needs to match API properties with _
    @SuppressWarnings('PMD.FieldNamingConventions')
    public class Request {
        public String model;
        public List<Message> messages = new List<Message>();
        public Integer max_tokens = 200;

        public Request model(String value) {
            model = value;
            return this;
        }

        public Request message(Message value) {
            messages.add(value);
            return this;
        }

        public String asJson() {
            return JSON.serialize(this);
        }
    }


    public class Message {
        public String role;
        public String content;

        public Message role(String value) {
            role = value;
            return this;
        }

        public Message content(String value) {
            content = value;
            return this;
        }
    }


    public class Response {
        public List<Choice> choices = new List<Choice>();

        public Response withChoice(Message message) {
            Choice choice = new Choice();
            choice.message = message;
            choices.add(choice);
            return this;
        }
    }


    // PMD Json Wrapper needs to match API properties with _
    @SuppressWarnings('PMD.FieldNamingConventions')
    public class Choice {
        public Message message;
        public Integer index;
        public String finish_reason;
    }
}