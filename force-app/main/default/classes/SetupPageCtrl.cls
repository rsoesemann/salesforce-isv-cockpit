public with sharing class SetupPageCtrl extends SetupCtrl {
   
    public SetupPackageNamespaces setupPackageNamespaces { get; set; }
    public SetupEmailService setupEmailService { get; set; }
    public SetupReparse setupReparse { get; set; }
    public SetupArchiveErrors setupArchive { get; set; }
    public SetupRestoreErrors setupRestore { get; set; }
    public SetupAppAnalytics setupAppAnalytics { get; set; }
    public SetupSlack setupSlack { get; set; }
    public SetupOpenAi setupOpenAi { get; set; }


    // CONSTRUCTOR

    public SetupPageCtrl() {
        setupPackageNamespaces = new SetupPackageNamespaces();
        setupEmailService = new SetupEmailService();
        setupReparse = new SetupReparse();
        setupArchive = new SetupArchiveErrors();
        setupRestore = new SetupRestoreErrors();
        setupAppAnalytics = new SetupAppAnalytics();
        setupSlack = new SetupSlack();
        setupOpenAi = new SetupOpenAi();
    }


    // PUBLIC

    public override List<SetupStep> steps() {
        return new List<SetupStep>{ setupPackageNamespaces, setupEmailService, setupAppAnalytics, setupSlack, setupOpenAi };
    }
}