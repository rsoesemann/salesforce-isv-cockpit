public with sharing abstract class SetupCtrl {

    public SetupCtrl controller { get; private set; }

    // CONSTRUCTOR

    public SetupCtrl() {
        controller = this;
    }


    // PUBLIC

    public abstract List<SetupStep> steps();


    public Integer getProgress() {
        Integer result = 0;

        List<SetupStep> steps = steps();

        for(SetupStep step : steps) {
            if(step.success) {
                result += 100;
            }
        }

        return result / steps.size();
    }


    public String getClasses() {
        return (getProgress() == 100) ? 'slds-progress-bar__value_success' : '';
    }
}