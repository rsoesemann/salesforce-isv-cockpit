public with sharing class SetupVerifyTokenizers extends SetupStep {

    public List<ErrorTokenizer__mdt> records { get; set; }


    // PUBLIC    

    public override ApexPages.Message getStatus() {
        records = new ErrorTokenizersSelector().allActiveInOrder();

        String message = String.format('{0} for {1} Tokenizers found.',
                            new List<String>{ setupLink('m00', 'CustomMetadata', 'Custom Metadata'), ''+ records.size()});
        ApexPages.Severity severity = (records.isEmpty()) ? ApexPages.Severity.ERROR : ApexPages.Severity.CONFIRM ;

        return new ApexPages.Message(severity, message);
    }


    public override String buttonLabel() {
        return null;
    }


    public override PageReference run() {
        return currentPage();
    }
}