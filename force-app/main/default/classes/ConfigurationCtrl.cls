public with sharing class ConfigurationCtrl {

    public ConfigureEmailService configureEmailService { get; set; }
    public ConfigurePackageNamespaces configureNamespaces { get; set; }


    // CONSTRUCTOR

    public ConfigurationCtrl() {
        configureEmailService = new ConfigureEmailService();
        configureNamespaces = new ConfigurePackageNamespaces();
    }
}