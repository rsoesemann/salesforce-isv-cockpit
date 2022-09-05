public class ApplicationException extends Exception {
    
    public void throwAuraHandled() {
        throwAuraHandled(this);
    }


    public void throwAuraHandled(Exception anyException) {
        throw auraHandled(anyException);
    }


    public AuraHandledException auraHandled(Exception ex) {
        AuraHandledException result = new AuraHandledException( ex.getMessage() );
        return result;
    }
}