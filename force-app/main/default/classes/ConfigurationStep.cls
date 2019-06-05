public abstract class ConfigurationStep {

    public String getMessage() {
        return getStatus().getSummary();
    }


    public String getSeverity() {
        return getStatus().getSeverity().name();
    }


    public PageReference doRun() {
        return run();
    }


    public String buttonLabel {
        get {
            return buttonLabel();
        }
    }


    public abstract ApexPages.Message getStatus();
    public abstract PageReference run();
    public abstract String buttonLabel();
}