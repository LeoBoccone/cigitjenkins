<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
	<apiVersion>33.0</apiVersion>
</ApexClass>@isTest
private class BlackListControllerTest {

    static testMethod void testConstructorWhitFeatureSwitchCRMI627On(){
        FeatureSwitch.enable('CRMI-627');
        SetupDataClass setup_data = new SetupDataClass();
        Boolean user_have_feature_access = true;
        setup_data.createUser();
        setup_data.featureAccessAllOnSettingForRunAsUser(user_have_feature_access);
        System.runAs(setup_data.TestingUser){
            List<Blacklist__c> current_blacklist_list = setup_data.getListOfRecords(20,false);
            List<Blacklist__c> removed_blacklist_list = setup_data.getListOfRecords(18,true);
            String base_query = setup_data.getBaseQuery();
            Set<String> requiered_data = setup_data.getRequieredData();
            Test.startTest();
                setup_data.setupClassUnderTest();
                Boolean is_crmi_627_enabled_and_user_have_access = setup_data.ClassUnderTest.getIsCurrentUserAllowedAndFeatureSwitchItsOn();
            Test.stopTest();
            System.assertEquals(true, is_crmi_627_enabled_and_user_have_access, 'CRMI-627 feature switch should be enabled and the user should have access.');
            System.assertEquals(true, setup_data.ClassUnderTest.SortOrder, 'SortOrder should be true');
            System.assertEquals('', setup_data.ClassUnderTest.InfoMessage.Summary, 'the message should be empty');
            System.assertEquals(30, setup_data.ClassUnderTest.BlacklistPerPage, 'This Blacklist records per pege should be 30');
            System.assertEquals(base_query, setup_data.ClassUnderTest.BLACKLIST_QUERY_BASE, 'This should be the base query:' + base_query);
            Schema.DescribeSObjectResult oppDescribe = Blacklist__c.sObjectType.getDescribe();
            Map<String, Schema.SObjectField> test_fields = oppDescribe.fields.getMap();
            System.assertEquals(test_fields , setup_data.ClassUnderTest.BlackListFields, 'The fields should be the equal');
            System.assertEquals(current_blacklist_list.size() , setup_data.ClassUnderTest.AllBlacklistCurrentSet.getRecords().size(), 'The lists should have the same size');
            System.assertEquals(removed_blacklist_list.size() , setup_data.ClassUnderTest.AllBlacklistRemovedSet.getRecords().size(), 'The lists should have the same size');
            System.assertEquals(true, requiered_data.containsAll(setup_data.ClassUnderTest.AllRequiredDataForCurrentRecords), 'The set should have the same elements');
            System.assertEquals(true, requiered_data.containsAll(setup_data.ClassUnderTest.FieldsToShow), 'The set should have the same elements');
            System.assertEquals(true, requiered_data.containsAll(setup_data.ClassUnderTest.SelectedFieldsToShow), 'The list should have the same elements');
            System.assertEquals(setup_data.ClassUnderTest.EligibleFields.size(), setup_data.ClassUnderTest.AllRequiredDataForCurrentRecords.size(), 'The list should have the same elements');
        }
    }

    static testMethod void testConstructorWhitFeatureSwitchCRMI22Off(){
        FeatureSwitch.disable('CRMI-627');
        SetupDataClass setup_data = new SetupDataClass();
        Boolean user_have_feature_access = true;
        setup_data.createUser();
        setup_data.featureAccessAllOnSettingForRunAsUser(user_have_feature_access);
        System.runAs(setup_data.TestingUser){
            Test.startTest();
                setup_data.setupClassUnderTest();
            Test.stopTest();
            System.assertEquals('This feature is not released yet.', setup_data.ClassUnderTest.InfoMessage.Summary, 'the message should be This feature is not released yet.');
        }
    }

    static testMethod void testConstructorWhitNotAccess(){
        FeatureSwitch.enable('CRMI-627');
        SetupDataClass setup_data = new SetupDataClass();
        Boolean user_have_feature_access = false;
        setup_data.createUser();
        setup_data.featureAccessAllOnSettingForRunAsUser(user_have_feature_access);
        System.runAs(setup_data.TestingUser){
            Test.startTest();
                setup_data.setupClassUnderTest();
            Test.stopTest();
            System.assertEquals('You Do Not Have Permission To Complete This Action.', setup_data.ClassUnderTest.InfoMessage.Summary, 'the message should be You Do Not Have Permission To Complete This Action.');
        }
    }

    static testMethod void testGetCurrentBlacklist(){
        FeatureSwitch.enable('CRMI-627');
        SetupDataClass setup_data = new SetupDataClass();
        Boolean user_have_feature_access = true;
        setup_data.createUser();
        setup_data.featureAccessAllOnSettingForRunAsUser(user_have_feature_access);
        System.runAs(setup_data.TestingUser){
            List<Blacklist__c> current_blacklist_list = setup_data.getListOfRecords(20,false);
            setup_data.setupClassUnderTest();
            Test.startTest();
                Component.Apex.PageBlockTable table = setup_data.ClassUnderTest.getCurrentRecords();
            Test.stopTest();
            system.assertNotEquals(null, table, 'The method should return a Table');
            system.assertEquals(true, table.childComponents[0] instanceOf Component.Apex.Column,'The first child component should be a Column ');
            Component.Apex.Column first_column = (Component.Apex.Column)table.childComponents[0];
            system.assertEquals('No', first_column.headerValue,'The first column heder should be No');
            system.assertEquals(true, first_column.childComponents[0] instanceOf Component.Apex.OutputText,'The first child component should be a OutputText ');
            Component.Apex.Column second_column = (Component.Apex.Column)table.childComponents[1];
            system.assertEquals(true, second_column.facets.header instanceOf Component.Apex.CommandLink,'The header of the second column shoud have a CommandLink Component');
            system.assertEquals(true, second_column.childComponents[0] instanceOf Component.Apex.OutputField,'The first child component should be a OutputField ');
            Set<String> extra_no_column = new Set<String>{'No'};
            extra_no_column.addAll(setup_data.ClassUnderTest.FieldsToShow);
            system.assertEquals(extra_no_column.size(), table.childComponents.size(),'The table columns should be the same that FiedlToShow set');

        }
    }

    static testMethod void testGetRemovedBlacklist(){
        FeatureSwitch.enable('CRMI-627');
        SetupDataClass setup_data = new SetupDataClass();
        Boolean user_have_feature_access = true;
        setup_data.createUser();
        setup_data.featureAccessAllOnSettingForRunAsUser(user_have_feature_access);
        System.runAs(setup_data.TestingUser){
            List<Blacklist__c> removed_blacklist_list = setup_data.getListOfRecords(20,true);
            setup_data.setupClassUnderTest();
            Test.startTest();
                Component.Apex.PageBlockTable table = setup_data.ClassUnderTest.getRemovedRecords();
            Test.stopTest();
            system.assertNotEquals(null, table, 'The method should return a Table');
            system.assertEquals(true, table.childComponents[0] instanceOf Component.Apex.Column,'The first child component should be a Column ');
            Component.Apex.Column first_column = (Component.Apex.Column)table.childComponents[0];
            system.assertEquals('No', first_column.headerValue,'The first column heder should be No');
            system.assertEquals(true, first_column.childComponents[0] instanceOf Component.Apex.OutputText,'The first child component should be a OutputText ');
            Component.Apex.Column second_column = (Component.Apex.Column)table.childComponents[1];
            system.assertEquals(true, second_column.facets.header instanceOf Component.Apex.CommandLink,'The header of the second column shoud have a CommandLink Component');
            system.assertEquals(true, second_column.childComponents[0] instanceOf Component.Apex.OutputField,'The first child component should be a OutputField ');
            Set<String> extra_required_data_for_removed_records_and_no_column = new Set<String>{'Removed_Date__c', 'Removed_by_User__c','No'};
            extra_required_data_for_removed_records_and_no_column.addAll(setup_data.ClassUnderTest.FieldsToShow);
            system.assertEquals(extra_required_data_for_removed_records_and_no_column.size(), table.childComponents.size(),'The table columns should be the same that FiedlToShow set');
        }
    }

    static testMethod void testGetRemovedRecordsToShow(){
        FeatureSwitch.enable('CRMI-627');
        SetupDataClass setup_data = new SetupDataClass();
        Boolean user_have_feature_access = true;
        setup_data.createUser();
        setup_data.featureAccessAllOnSettingForRunAsUser(user_have_feature_access);
        System.runAs(setup_data.TestingUser){
            setup_data.getListOfRecords(5,true);
            String query = setup_data.getBaseQuery() + ', Removed_Date__c,Removed_by_User__c FROM Blacklist__c Where Removed_Date__c != null';
            setup_data.setupClassUnderTest();
            Test.startTest();
                List<Blacklist__c> blacklist_removed_users = setup_data.ClassUnderTest.executeBlacklistQuery(query);
                List<Blacklist__c> removed_to_show = setup_data.ClassUnderTest.getRemovedRecordsToShow();
            Test.stopTest();
            System.assertEquals(blacklist_removed_users.size(), removed_to_show.size(), 'The two lists should be the same size');
            System.assertEquals(true,blacklist_removed_users.equals(removed_to_show),'The two list should should be equal');

        }
    }

    static testMethod void testGetCurrentRecordsToShow(){
        FeatureSwitch.enable('CRMI-627');
        SetupDataClass setup_data = new SetupDataClass();
        Boolean user_have_feature_access = true;
        setup_data.createUser();
        setup_data.featureAccessAllOnSettingForRunAsUser(user_have_feature_access);
        System.runAs(setup_data.TestingUser){
            setup_data.getListOfRecords(5,false);
            String query = setup_data.getBaseQuery() + ' FROM Blacklist__c Where Removed_Date__c = null';
            setup_data.setupClassUnderTest();
            Test.startTest();
                List<Blacklist__c> blacklist_current_users = setup_data.ClassUnderTest.executeBlacklistQuery(query);
                List<Blacklist__c> current_to_show = setup_data.ClassUnderTest.getCurrentRecordsToShow();
            Test.stopTest();
            System.assertEquals(blacklist_current_users.size(), current_to_show.size(), 'The two lists should be the same size');
            System.assertEquals(true,blacklist_current_users.equals(current_to_show),'The two list should be equal');

        }
    }

    static testMethod void testSelectedBlackListRecord(){
        FeatureSwitch.enable('CRMI-627');
        SetupDataClass setup_data = new SetupDataClass();
        Boolean user_have_feature_access = true;
        setup_data.createUser();
        setup_data.featureAccessAllOnSettingForRunAsUser(user_have_feature_access);
        System.runAs(setup_data.TestingUser){
            setup_data.setupClassUnderTest();
            List<Blacklist__c> blacklist_current_users = setup_data.getListOfRecords(1,false);
            String selected_blacklist_id =blacklist_current_users.get(0).Id;
            setup_data.ClassUnderTest.IdBlackListRecord = selected_blacklist_id;
            Test.startTest();
                setup_data.ClassUnderTest.selectedBlackListRecord();
            Test.stopTest();
            System.assertEquals(selected_blacklist_id, setup_data.ClassUnderTest.BlacklistRecord.Id, 'The Id should be this: '+selected_blacklist_id);
        }
    }

    static testMethod void testSelectedFields(){
        FeatureSwitch.enable('CRMI-627');
        SetupDataClass setup_data = new SetupDataClass();
        Boolean user_have_feature_access = true;
        setup_data.createUser();
        setup_data.featureAccessAllOnSettingForRunAsUser(user_have_feature_access);
        System.runAs(setup_data.TestingUser){
            setup_data.setupClassUnderTest();
            Integer fields_to_show_before = setup_data.ClassUnderTest.FieldsToShow.size();
            Integer selected_fields_to_show_before = setup_data.ClassUnderTest.SelectedFieldsToShow.size();
            Test.startTest();
                setup_data.ClassUnderTest.SelectedFieldsToShow.remove(0);
                Integer selected_fields_to_show_after = setup_data.ClassUnderTest.SelectedFieldsToShow.size();
                setup_data.ClassUnderTest.selectedFields();
            Test.stopTest();
            System.assertEquals(selected_fields_to_show_before, fields_to_show_before, 'The two list should be the same size');
            System.assertEquals(selected_fields_to_show_after, setup_data.ClassUnderTest.FieldsToShow.size(), 'The two list should be the same size');
        }
    }

    static testMethod void testSortCurrentRecordColumn(){
        FeatureSwitch.enable('CRMI-627');
        SetupDataClass setup_data = new SetupDataClass();
        Boolean user_have_feature_access = true;
        setup_data.createUser();
        setup_data.featureAccessAllOnSettingForRunAsUser(user_have_feature_access);
        System.runAs(setup_data.TestingUser){
            List<Blacklist__c> blacklist_list= setup_data.getListOfRecords(5,false);
            blacklist_list.get(0).First_name__c = 'Bohdan';
            blacklist_list.get(1).First_name__c = 'Roberto';
            blacklist_list.get(2).First_name__c = 'Almir';
            blacklist_list.get(3).First_name__c = 'Russell';
            blacklist_list.get(4).First_name__c = 'Richella';
            update blacklist_list;
            setup_data.setupClassUnderTest();
            setup_data.ClassUnderTest.ColumnToSort = 'First name';
            setup_data.ClassUnderTest.SortOrder = true;
            Test.startTest();
                List<Blacklist__c> not_sorted_list = setup_data.ClassUnderTest.getCurrentRecordsToShow();
                setup_data.ClassUnderTest.sortCurrentRecordColumn();
                List<Blacklist__c> sorted_list = setup_data.ClassUnderTest.getCurrentRecordsToShow();
            Test.stopTest();
            System.assertEquals('Bohdan', not_sorted_list.get(0).First_name__c, 'The first name should be Bohdan');
            System.assertEquals('Almir', sorted_list.get(0).First_name__c, 'The first name should be Almir');
        }
    }

    static testMethod void testSortRemovedRecordColumn(){
        FeatureSwitch.enable('CRMI-627');
        SetupDataClass setup_data = new SetupDataClass();
        Boolean user_have_feature_access = true;
        setup_data.createUser();
        setup_data.featureAccessAllOnSettingForRunAsUser(user_have_feature_access);
        System.runAs(setup_data.TestingUser){
            List<Blacklist__c> blacklist_list= setup_data.getListOfRecords(5,true);
            blacklist_list.get(0).First_name__c = 'Bohdan';
            blacklist_list.get(1).First_name__c = 'Roberto';
            blacklist_list.get(2).First_name__c = 'Almir';
            blacklist_list.get(3).First_name__c = 'Russell';
            blacklist_list.get(4).First_name__c = 'Richella';
            update blacklist_list;
            setup_data.setupClassUnderTest();
            setup_data.ClassUnderTest.ColumnToSort = 'First name';
            setup_data.ClassUnderTest.SortOrder = false;
            Test.startTest();
                List<Blacklist__c> not_sorted_list = setup_data.ClassUnderTest.getRemovedRecordsToShow();
                setup_data.ClassUnderTest.sortRemovedRecordColumn();
                List<Blacklist__c> sorted_list = setup_data.ClassUnderTest.getRemovedRecordsToShow();
            Test.stopTest();
            System.assertEquals('Bohdan', not_sorted_list.get(0).First_name__c, 'The first name should be Bohdan');
            System.assertEquals('Russell', sorted_list.get(0).First_name__c, 'The first name should be Almir');
        }
    }

    static testMethod void testExecuteBlacklistQueryFail(){
        FeatureSwitch.enable('CRMI-627');
        SetupDataClass setup_data = new SetupDataClass();
        Boolean user_have_feature_access = true;
        setup_data.createUser();
        setup_data.featureAccessAllOnSettingForRunAsUser(user_have_feature_access);
        System.runAs(setup_data.TestingUser){
            setup_data.setupClassUnderTest();
            String query = setup_data.getBaseQuery() + ' FROM Blacklist__ Where Removed_Date__c = null';
            Test.startTest();
                setup_data.ClassUnderTest.executeBlacklistQuery(query);
            Test.stopTest();
            String error_message = 'Ooops, something appears to have gone wrong. Please try and refresh the page or if the problem continues, raise a ticket and include a screenshot. sObject type \'Blacklist__\' is not supported. If you are attempting to use a custom object, be sure to append the \'__c\' after the entity name. Please reference your WSDL or the describe call for the appropriate names.';
            System.assertEquals(error_message, setup_data.ClassUnderTest.InfoMessage.Summary, 'the message should be: '+ error_message);
        }
    }

    static testMethod void testShowAddBlacklistPanel(){
        FeatureSwitch.enable('CRMI-627');
        SetupDataClass setup_data = new SetupDataClass();
        Boolean user_have_feature_access = true;
        setup_data.createUser();
        setup_data.featureAccessAllOnSettingForRunAsUser(user_have_feature_access);
        System.runAs(setup_data.TestingUser){
            setup_data.setupClassUnderTest();
            Test.startTest();
                setup_data.ClassUnderTest.showAddBlacklistPanel();
            Test.stopTest();
            System.assertEquals(false, setup_data.ClassUnderTest.ShowRemoveBlacklist, 'ShowRemoveBlacklist should be false');
            System.assertEquals(true, setup_data.ClassUnderTest.ShowAddBlacklist, 'ShowAddBlacklist should be true');
        }
    }

    static testMethod void testShowRemoveBlacklistPanel(){
        FeatureSwitch.enable('CRMI-627');
        SetupDataClass setup_data = new SetupDataClass();
        Boolean user_have_feature_access = true;
        setup_data.createUser();
        setup_data.featureAccessAllOnSettingForRunAsUser(user_have_feature_access);
        System.runAs(setup_data.TestingUser){
            setup_data.setupClassUnderTest();
            Test.startTest();
                setup_data.ClassUnderTest.showRemoveBlacklistPanel();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.ShowRemoveBlacklist, 'ShowRemoveBlacklist should be true');
            System.assertEquals(false, setup_data.ClassUnderTest.ShowAddBlacklist, 'ShowAddBlacklist should be false');
        }
    }

    static testMethod void testShowApproveSection(){
        FeatureSwitch.enable('CRMI-627');
        SetupDataClass setup_data = new SetupDataClass();
        Boolean user_have_feature_access = true;
        setup_data.createUser();
        setup_data.featureAccessAllOnSettingForRunAsUser(user_have_feature_access);
        System.runAs(setup_data.TestingUser){
            setup_data.setupClassUnderTest();
            Test.startTest();
                setup_data.ClassUnderTest.showApproveSection();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.ShowRemoveBlacklist, 'ShowRemoveBlacklist should be true');
            System.assertEquals(false, setup_data.ClassUnderTest.ShowAddBlacklist, 'ShowAddBlacklist should be false');
            System.assertEquals(true, setup_data.ClassUnderTest.ShowApproveSection, 'ShowApproveSection should be true');
            System.assertEquals(setup_data.ClassUnderTest.BlacklistRecord, setup_data.ClassUnderTest.BlacklistNewRecord, 'the two records should be the same');
        }
    }

    static testMethod void testCancelConfirmation(){
        FeatureSwitch.enable('CRMI-627');
        SetupDataClass setup_data = new SetupDataClass();
        Boolean user_have_feature_access = true;
        setup_data.createUser();
        setup_data.featureAccessAllOnSettingForRunAsUser(user_have_feature_access);
        System.runAs(setup_data.TestingUser){
            setup_data.setupClassUnderTest();
            Test.startTest();
                setup_data.ClassUnderTest.cancelConfirmation();
            Test.stopTest();
            System.assertEquals(false, setup_data.ClassUnderTest.ShowRemoveBlacklist, 'ShowRemoveBlacklist should be false');
            System.assertEquals(true, setup_data.ClassUnderTest.ShowAddBlacklist, 'ShowAddBlacklist should be true');
            System.assertEquals(false, setup_data.ClassUnderTest.ShowApproveSection, 'ShowApproveSection should be false');
        }
    }

    static testMethod void TestConfirmAddBlacklisAction() {
        FeatureSwitch.enable('CRMI-627');
        SetupDataClass setup_data = new SetupDataClass();
        Boolean user_have_feature_access = true;
        setup_data.createUser();
        setup_data.featureAccessAllOnSettingForRunAsUser(user_have_feature_access);
        System.runAs(setup_data.TestingUser){
            setup_data.setupClassUnderTest();
            Blacklist__c black_list_record = setup_data.createCurrentBlacklistUser();
            setup_data.ClassUnderTest.BlacklistNewRecord = black_list_record;
            setup_data.ClassUnderTest.BlacklistNewRecord.Type__c = 'Full Match';
            Test.StartTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.StopTest();
            System.assertEquals('Add to Blacklist successfully', setup_data.ClassUnderTest.InfoMessage.Summary, 'should recive this massage Add to Blacklist successfully');
            System.assertEquals('CONFIRM', setup_data.ClassUnderTest.InfoMessage.Severity, 'the severity should be confirm');
            System.assertEquals(1 , CsApi.HttpRequestsThatWereSentInTests.size(), 'Expected 1 http callout to be sent to the backend');
            System.assertEquals(true,(new List<HttpRequest>(CsApi.HttpRequestsThatWereSentInTests)).get(0).getBody().contains('CsAddBlackListRecord'),'The correct AddBlackListRecord command was not sent');
            System.assertEquals(true, setup_data.ClassUnderTest.ShowRemoveBlacklist, 'ShowRemoveBlacklist should be true');
            System.assertEquals(false, setup_data.ClassUnderTest.ShowAddBlacklist, 'ShowAddBlacklist should be false');
            System.assertEquals(false, setup_data.ClassUnderTest.ShowApproveSection, 'ShowApproveSection should be false');

            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('FirstName'),black_list_record.First_name__c);
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('LastName'),black_list_record.Last_name__c);
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('PostCode'),black_list_record.Post_Code_Official__c);
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('HomePhone'),black_list_record.Home_Phone__c);
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('MobilePhone'),black_list_record.Mobile_Phone__c);
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('WorkPhone'),black_list_record.Work_phone__c);
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('EmployerName'),black_list_record.Employers_name__c);
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('CardNumber'),black_list_record.Card_Number__c);
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('BankAccount'),black_list_record.Bank_Account__c);
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('SortCode'),black_list_record.Sort_Code__c);
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('Email'),black_list_record.Email__c);
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('PeselNumber'),black_list_record.PESEL__c);
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('IdentificationDocumentId'),black_list_record.Id_Document_Number__c);
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('MiddleName'),black_list_record.Middle_name__c);
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('MaidenName'),black_list_record.Mothers_Maiden_Name__c);
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('CityOfficial'),black_list_record.City_Official__c);
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('StreetOfficial'),black_list_record.Street_Official__c);
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('HouseNumberOfficial'),String.valueOf(black_list_record.House_Number_Official__c));
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('FlatNumberOfficial'),String.valueOf(black_list_record.Flat_Number_Official__c));
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('CityResedential'),black_list_record.City_Residential__c);
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('StreetResedential'),black_list_record.Street_Residential__c);
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('HouseNumberResedential'),String.valueOf(black_list_record.House_Number_Residential__c));
            System.assertEquals(setup_data.ClassUnderTest.BlacklistFieldsMap.get('FlatNumberResedential'),String.valueOf(black_list_record.Flat_Number_Residential__c));
        }
    }

    static testMethod void testUnsuccesfulConfirmAddBlacklisAction() {
        FeatureSwitch.enable('CRMI-627');
        SetupDataClass setup_data = new SetupDataClass();
        Boolean user_have_feature_access = true;
        setup_data.createUser();
        setup_data.featureAccessAllOnSettingForRunAsUser(user_have_feature_access);
        System.runAs(setup_data.TestingUser){
            setup_data.setupClassUnderTest();
            Test.startTest();
                setup_data.ClassUnderTest.confirmAction();
            Test.stopTest();
            System.assertEquals(true, setup_data.ClassUnderTest.InfoMessage.HasMessage, 'the page should have a message');
            System.assertEquals('Must specify one field and Type', setup_data.ClassUnderTest.InfoMessage.Summary, 'should recive this massage Must specify Type');
            System.assertEquals('FATAL', setup_data.ClassUnderTest.InfoMessage.Severity, 'the severity should be FATAL');
            System.assertEquals(true, setup_data.ClassUnderTest.ShowRemoveBlacklist, 'ShowRemoveBlacklist should be true');
            System.assertEquals(false, setup_data.ClassUnderTest.ShowAddBlacklist, 'ShowAddBlacklist should be false');
        }
    }

    public class SetupDataClass {
        public Loan_Application__c TestLoanApp {get; set;}
        public BlackListController ClassUnderTest {get; set;}
        public User TestingUser {get; set;}

        private void createUser(){
            TestingUser = UserTestData.getUserForTest().setProfile(ProfileUtilities.ProfileType.FINANCE).save().getRecord();
        }

        public void setupClassUnderTest(){
            ClassUnderTest = new BlackListController();
        }

        public void featureAccessAllOnSettingForRunAsUser(Boolean user_have_feature_access){
            if(user_have_feature_access){
                TestDataClass.createFeatureAccessAllOnSettingForRunAsUser(TestingUser);
            }else{
                TestDataClass.createFeatureAccessAllOffSettingForRunAsUser(TestingUser);
            }
        }

        public Blacklist__c createCurrentBlacklistUser(){
            Blacklist__c blacklist =  BlacklistBuilder.getBuilder()
                                        .setFirstName(al.RandomStringUtils.randomAlphanumeric(10))
                                        .setLastName(al.RandomStringUtils.randomAlphanumeric(10))
                                        .setMiddleName(al.RandomStringUtils.randomAlphanumeric(10))
                                        .setMothersMaidenName(al.RandomStringUtils.randomAlphanumeric(10))
                                        .setPESEL(al.RandomStringUtils.randomAlphanumeric(10))
                                        .setEmail(al.RandomStringUtils.randomAlphanumeric(10) + '@test.com')
                                        .setBankAccount(al.RandomStringUtils.randomAlphanumeric(10))
                                        .setCityOfficial(al.RandomStringUtils.randomAlphanumeric(10))
                                        .setCityResidential(al.RandomStringUtils.randomAlphanumeric(10))
                                        .setEmployersName(al.RandomStringUtils.randomAlphanumeric(10))
                                        .setIdDocumentNumber(al.RandomStringUtils.randomAlphanumeric(10))
                                        .setPostCodeOfficial(al.RandomStringUtils.randomAlphanumeric(10))
                                        .setPostCodeResidential(al.RandomStringUtils.randomAlphanumeric(10))
                                        .setStreetOfficial(al.RandomStringUtils.randomAlphanumeric(10))
                                        .setSortCode(al.RandomStringUtils.randomAlphanumeric(10))
                                        .setStreetResidential(al.RandomStringUtils.randomAlphanumeric(10))
                                        .setWorkphone(al.RandomStringUtils.randomAlphanumeric(10))
                                        .setMobilePhone(al.RandomStringUtils.randomAlphanumeric(10))
                                        .setFlatNumberOfficial('1')
                                        .setFlatNumberResidential('4')
                                        .setHouseNumberOfficial('123')
                                        .setHouseNumberResidential('321')
                                        .setAddedByUser(TestingUser)
                                        .getRecord();
            return blacklist;
        }

        public List<Blacklist__c> getListOfRecords(Integer number_of_records, Boolean removed){
            List<Blacklist__c> blacklist_list = new List<Blacklist__c>();
            for(Integer i = 0; i < number_of_records; i++){
                Blacklist__c blacklist_clone = createCurrentBlacklistUser();
                if(removed){
                    blacklist_clone.Removed_Date__c = Date.today();
                    blacklist_clone.Removed_by_User__c = TestingUser.Id;
                }
                blacklist_list.add(blacklist_clone);
            }
            insert blacklist_list;
            return blacklist_list;
        }

        public String getBaseQuery(){
            String base_query = 'SELECT Id,First_name__c,Middle_name__c,Last_name__c,Home_Phone__c,Card_Number__c,PESEL__c,Id_Document_Number__c,Mothers_Maiden_Name__c, Work_phone__c,Employers_name__c,Bank_Account__c,Sort_Code__c,Email__c,Mobile_Phone__c,Post_Code_Official__c,'
            +'Post_Code_Residential__c,City_Official__c,City_Residential__c,Street_Official__c,Street_Residential__c,House_Number_Official__c,House_Number_Residential__c,Flat_Number_Official__c,Flat_Number_Residential__c,Type__c,Added_By_User__c, CreatedDate';
            return base_query;
        }

        public Set<String> getRequieredData(){
            Set<String> requiered_data = new Set<String>{'Type__c','First_name__c', 'Middle_name__c','Last_name__c','PESEL__c','Id_Document_Number__c','Work_phone__c','Work_phone__c','Home_Phone__c','Employers_name__c','Bank_Account__c','Card_Number__c','Sort_Code__c','Email__c','Mobile_Phone__c',
            'Post_Code_Official__c','Post_Code_Residential__c','City_Official__c','City_Residential__c','Street_Official__c','Street_Residential__c','House_Number_Official__c','House_Number_Residential__c','Flat_Number_Official__c','Flat_Number_Residential__c','CreatedDate','Added_By_User__c'};
            return requiered_data;
        }

    }
}<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
	<apiVersion>33.0</apiVersion>
</ApexClass>