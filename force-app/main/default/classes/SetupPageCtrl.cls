public with sharing class SetupPageCtrl extends SetupCtrl {

    public SetupEmailService setupEmailService { get; set; }
    public SetupPackageNamespaces setupPackageNamespaces { get; set; }
    public SetupRetryUnparseable setupRetryUnparseable { get; set; }
    public SetupArchiveErrors setupArchive { get; set; }
    public SetupRestoreErrors setupRestore { get; set; }


    // CONSTRUCTOR

    public SetupPageCtrl() {
        setupEmailService = new SetupEmailService();
        setupPackageNamespaces = new SetupPackageNamespaces();
        setupRetryUnparseable = new SetupRetryUnparseable();
        setupArchive = new SetupArchiveErrors();
        setupRestore = new SetupRestoreErrors();
    }


    // PUBLIC

    public override List<SetupStep> steps() {
        return new List<SetupStep>{ setupEmailService, setupPackageNamespaces, setupRetryUnparseable, setupArchive };
    }
}