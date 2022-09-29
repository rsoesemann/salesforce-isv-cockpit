public with sharing class SetupPageCtrl extends SetupCtrl {
   
    public SetupPackageNamespaces setupPackageNamespaces { get; set; }
    public SetupAppAnalytics setupAppAnalytics { get; set; }
    public SetupEmailService setupEmailService { get; set; }
    public SetupReparse setupReparse { get; set; }
    public SetupArchiveErrors setupArchive { get; set; }
    public SetupRestoreErrors setupRestore { get; set; }


    // CONSTRUCTOR

    public SetupPageCtrl() {
        setupPackageNamespaces = new SetupPackageNamespaces();
        setupEmailService = new SetupEmailService();
        setupAppAnalytics = new SetupAppAnalytics();
        setupReparse = new SetupReparse();
        setupArchive = new SetupArchiveErrors();
        setupRestore = new SetupRestoreErrors();
    }


    // PUBLIC

    public override List<SetupStep> steps() {
        return new List<SetupStep>{ setupEmailService, setupPackageNamespaces };
    }
}