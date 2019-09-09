public with sharing class SetupCtrl {

    public SetupEmailService setupEmailService { get; set; }
    public SetupPackageNamespaces setupPackageNamespaces { get; set; }


    // CONSTRUCTOR

    public SetupCtrl() {
        setupEmailService = new SetupEmailService();
        setupPackageNamespaces = new SetupPackageNamespaces();
    }
}