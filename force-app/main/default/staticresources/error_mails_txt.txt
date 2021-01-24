
Apex script unhandled exception by user/organization: 005500000024uNj/00D000000000001

Visualforce Page: /apex/nsB__myPage

caused by: System.NullPointerException: Attempt to de-reference a null object

Class.NSB.MyController.createSelectOptions: line 143, column 1
Class.NSB.MyController.<init>: line 31, column 1
Class.NSB.MyController.<init>: line 3, column 1

&

Apex script unhandled trigger exception by user/organization: 005500000024uNj/00D000000000001

NSA.TriggerDelete: execution of BeforeInsert

caused by: System.DmlException: Delete failed. First exception on row 0 with id a031t00000RuMxyAAF; first error: ENTITY_IS_DELETED, entity is deleted: []

Trigger.NSA.TriggerDelete: line 18, column 1

&

Apex script unhandled exception by user/organization: 005500000024uNj/00D000000000001

Failed to process batch for class 'NSA.IteratorImpl' for job id '7071v0000680gLG'

caused by: System.DmlException: Insert failed. First exception on row 0; first error: STRING_TOO_LONG, Log Status: Datenwert zu groß: Fehler NSA.RetrieveAction.UnsuccessfulCalloutException (max length=80): [Name]

Class.NSA.DMLManager.performDMLOperation: line 106, column 1
Class.NSA.DMLManager.insertAsUser: line 35, column 1
Class.NSA.Logger.createErrorLog: line 16, column 1
Class.NSA.RetrieveAction.onError: line 48, column 1
Class.NSA.Executor.execute: line 32, column 1
Class.NSA.IteratorImpl.execute: line 22, column 11

&

Apex script unhandled exception by user/organization: 005500000024uNj/00D000000000001

Visualforce Page: /apex/nsB__myPage



caused by: System.LimitException:Too many SOQL queries: 101

Class.NSA.MyController.loadContent: line 78, column 1
Class.NSA.MyController.<init>: line 12, column 1
Class.NSA.MyController.initTableOwner: line 326, column 1
Class.NSA.MyController.init: line 129, column 1
Class.NSA.MyController.<init>: line 72, column 1


&

Apex script unhandled exception by user/organization: 005500000024uNj/00D000000000001

Failed to process batch for class 'NSA.QueryImpl' for job id '7071t00001modVz'

caused by: System.DmlException: Insert failed. First exception on row 0; first error: CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, CleverReachApp.TriggerCRLogDelete: execution of BeforeInsert

caused by: System.DmlException: Delete failed. First exception on row 0 with id a031t00000RuMxyAAF; first error: ENTITY_IS_DELETED, entity is deleted: []

Trigger.NSA.TriggerDelete: line 18, column 1: []

Class.NSA.DMLManager.performDMLOperation: line 106, column 1
Class.NSA.DMLManager.insertAsUser: line 35, column 1
Class.NSA.Logger.createErrorLog: line 16, column 1
Class.NSA.SendAction.onError: line 80, column 1
Class.NSA.Executor.execute: line 32, column 1
Class.NSA.QueryImpl.execute: line 23, column 1

&

Apex script unhandled exception by user/organization: 005500000024uNj/00D000000000001

Failed to process batch for class 'NSA.PREFIX_MyBatchOb' for job id '7073X00009N7cij'

caused by: System.NullPointerException: Attempt to de-reference a null object

External entry point

&

Apex script unhandled exception by user/organization: 005500000024uNj/00D000000000001

Failed to process batch for class 'NSA.BatchClass' for job id '707670000Ctreje'

caused by: System.DmlException: Update failed. First exception on row 9 with id a7p67000000TiD6AAK; first error: CANNOT_EXECUTE_FLOW_TRIGGER, We can't save this record because the “Shizzle_Mizzle” process failed. Give your Salesforce admin these details. This error occurred when the flow tried to update records: CANNOT_EXECUTE_FLOW_TRIGGER: We can't save this record because the “NSA SAT User Story Default - stable_v3” process failed. Give your Salesforce admin these details. This error occurred when the flow tried to update records: CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY: NSA.AccountTrigger: execution of AfterUpdate

caused by: System.AsyncException: Database.executeBatch cannot be called from a batch start, batch execute, or future method.

(NSA)



. You can look up ExceptionCode values in the SOAP API Developer Guide. Error ID: 265498433-10568 (-883246653). You can look up ExceptionCode values in the SOAP API Developer Guide. Error ID: 265498433-10569 (1006372730): []

Class.NSA.Utilities.Secure_DML: line 429, column 1
Class.NSA.Utilities.Secure_DML: line 493, column 1
Class.NSA.MyJob.execute: line 105, column 1

&

Apex script unhandled exception by user/organization: 005500000024uNj/00D000000000001

Failed to process batch for class 'NSA.MyBatch' for job id '7074J00002Cz4EI'

caused by: System.NullPointerException: Attempt to de-reference a null object

External entry point

&

Apex script unhandled exception by user/organization: 005500000024uNj/00D000000000001

Failed to invoke future method 'public static void myFuture(String, String)' on class 'NSA.MyAPI' for job id '7073b000072aIjN'

&

Apex script unhandled exception by user/organization: 005500000024uNj/00D000000000001

Scheduled job 'Copado' threw unhandled exception.

caused by: System.FinalException: ApexPages.addMessage can only be called from a Visualforce page

Class.NSA.ContactsManagerCtrl.getAccounts: line 125, column 1
Class.NSA.ContactsManagerCtrl.<init>: line 44, column 1
Class.NSA.AccountHelper.isEnabled: line 7, column 1
Class.NSA.Scheduler.execute: line 3, column 1

&

Apex script unhandled exception by user/organization: 005500000024uNj/00D000000000001

Scheduled job 'Refresh Metadata' threw unhandled exception.

caused by: System.QueryException: List has no rows for assignment to SObject

Class.NSA.MySchedulable.execute: line 7, column 1