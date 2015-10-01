public with sharing class BlackListController {

    @TestVisible private final String BLACKLIST_QUERY_BASE = 'SELECT Id,First_name__c,Middle_name__c,Last_name__c,Home_Phone__c,Card_Number__c,PESEL__c,Id_Document_Number__c,Mothers_Maiden_Name__c, Work_phone__c,Employers_name__c,Bank_Account__c,Sort_Code__c,Email__c,Mobile_Phone__c,Post_Code_Official__c,'
        +'Post_Code_Residential__c,City_Official__c,City_Residential__c,Street_Official__c,Street_Residential__c,House_Number_Official__c,House_Number_Residential__c,Flat_Number_Official__c,Flat_Number_Residential__c,Type__c,Added_By_User__c, CreatedDate';
    @TestVisible private Map<String, Schema.SObjectField> BlackListFields;
    private CsApiConfig Config;
    public Integer  BlacklistPerPage {get; set;}
    public ApexPages.StandardSetController AllBlacklistCurrentSet {get; private set;}
    public ApexPages.StandardSetController AllBlacklistRemovedSet {get; private set;}
    public MessageUtility InfoMessage {get; private set;}
    public Blacklist__c BlacklistRecord {get; private set;}
    @TestVisible public Blacklist__c BlacklistNewRecord {get; private set;}
    public String IdBlackListRecord {get; set;}
    public String ColumnToSort {get; set;}
    @TestVisible private Set<String> AllRequiredDataForCurrentRecords = new  Set<String>();
    public Set<String> FieldsToShow {get; private set;}
    public List<String> SelectedFieldsToShow {get; set;}
    public List<SelectOption> EligibleFields {get; set;}
    @TestVisible private Boolean SortOrder;
    public Map<Id,WrapBlacklist> WrapMap {get; private set;}
    public Boolean ShowRemoveBlacklist {get; private set;}
    public Boolean ShowAddBlacklist {get; private set;}
    public Boolean ShowApproveSection {get; private set;}

    @TestVisible private Map<String,String> BlacklistFieldsMap;

    public BlackListController(){
        BlacklistPerPage = 30;
        InfoMessage = new MessageUtility();
        if(getIsCurrentUserAllowedAndFeatureSwitchItsOn()){
            initVariables();
            initRequiredFields();
            searchCurrentRecords();
            searchRemovedRecords();
            initFieldsData();
        }
    }

    public Boolean getIsCurrentUserAllowedAndFeatureSwitchItsOn(){
        if(FeatureSwitch.getSwitch('CRMI-627').isFeatureDisabled()){
            InfoMessage.showInfo('This feature is not released yet.');
            return false;
        }else if(!isCurrentUserNotAllowedAccessToBlacklist()){
            InfoMessage.showInfo('You Do Not Have Permission To Complete This Action.');
            return false;
        }
        return true;
    }

    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.BLacklist__c.FieldSets.Fields_To_Show.getFields();
    }


    private void initVariables(){
        WrapMap  = new Map<Id,WrapBlacklist>();
        FieldsToShow = new  Set<String>();
        SelectedFieldsToShow = new  List<String>();
        EligibleFields = new List<SelectOption>();
        SortOrder = true;
        IdBlackListRecord = '';
        BlacklistRecord = new Blacklist__c();
        BlacklistNewRecord = new Blacklist__c();
        ColumnToSort = '';
        ShowRemoveBlacklist = true;
        ShowAddBlacklist = false;
        ShowApproveSection = false;
    }

    private void initRequiredFields(){
        AllRequiredDataForCurrentRecords  = new Set<String>{'Type__c','First_name__c', 'Middle_name__c','Last_name__c','PESEL__c','Id_Document_Number__c','Work_phone__c','Home_Phone__c','Employers_name__c','Bank_Account__c','Card_Number__c','Sort_Code__c','Email__c','Mobile_Phone__c',
        'Post_Code_Official__c','Post_Code_Residential__c','City_Official__c','City_Residential__c','Street_Official__c','Street_Residential__c','House_Number_Official__c','House_Number_Residential__c','Flat_Number_Official__c','Flat_Number_Residential__c','CreatedDate','Added_By_User__c'};
        FieldsToShow.addAll(AllRequiredDataForCurrentRecords);
        SelectedFieldsToShow.addAll(FieldsToShow);
    }

    private void initFieldsData(){
        Schema.DescribeSObjectResult opp_describe = Blacklist__c.sObjectType.getDescribe();
        BlackListFields = opp_describe.fields.getMap();
        for(String required_data: AllRequiredDataForCurrentRecords) {
            for(Schema.SObjectField field: BlackListFields.values()) {
                if(required_data == field.getDescribe().getName()){
                    if(field.getDescribe().getName() == 'Type__c'){
                        EligibleFields.add(new SelectOption(field.getDescribe().getName(),field.getDescribe().getLabel(),true));
                    }else{
                        EligibleFields.add(new SelectOption(field.getDescribe().getName(),field.getDescribe().getLabel()));
                    }
                }
            }
        }
    }

    private void searchCurrentRecords(){
        String query = BLACKLIST_QUERY_BASE + ' FROM Blacklist__c Where Removed_Date__c = null';
        List<Blacklist__c> blacklist_current_records = executeBlacklistQuery(query);
        uploadNoColumnValues(blacklist_current_records);
        AllBlacklistCurrentSet = new ApexPages.StandardSetController(blacklist_current_records);
        AllBlacklistCurrentSet.setPageSize(BlacklistPerPage);
    }

    private void searchRemovedRecords(){
        String query = BLACKLIST_QUERY_BASE + ', Removed_Date__c,Removed_by_User__c FROM Blacklist__c Where Removed_Date__c != null';
        List<Blacklist__c> blacklist_removed_records = executeBlacklistQuery(query);
        uploadNoColumnValues(blacklist_removed_records);
        AllBlacklistRemovedSet = new ApexPages.StandardSetController(blacklist_removed_records);
        AllBlacklistRemovedSet.setPageSize(BlacklistPerPage);
    }

    public Boolean isCurrentUserNotAllowedAccessToBlacklist(){
        FeatureAccess__c access = CustomSettingsHandler.FeatureAccessHandler.getCustomSettingsInstance();
        return Boolean.valueOf(Access.get('Blacklist__c') == true);
    }

    public Component.Apex.PageBlockTable getCurrentRecords(){
        Component.Apex.PageBlockTable table = new Component.Apex.PageBlockTable(var='BlacklistRecord');
        table.expressions.value='{!CurrentRecordsToShow}';
        if(getIsCurrentUserAllowedAndFeatureSwitchItsOn()){
            table.childComponents.add(addNumberColumn());
            table = uploadTable(table, FieldsToShow, 'current');
        }
        return table;
    }

    public Component.Apex.PageBlockTable getRemovedRecords(){
        Component.Apex.PageBlockTable table = new Component.Apex.PageBlockTable(var='BlacklistRecord');
        table.expressions.value='{!RemovedRecordsToShow}';
        if(getIsCurrentUserAllowedAndFeatureSwitchItsOn()){
            Set<String> extra_required_data_for_removed_records = new Set<String>();
            extra_required_data_for_removed_records.addAll(FieldsToShow);
            extra_required_data_for_removed_records.addAll(new Set<String>{'Removed_Date__c', 'Removed_by_User__c'});
            table.childComponents.add(addNumberColumn());
            table = uploadTable(table, extra_required_data_for_removed_records, 'removed');
        }
        return table;
    }

    private Component.Apex.PageBlockTable uploadTable(Component.Apex.PageBlockTable table, Set<String> required_data, String type){
        for(String data: required_data) {
            for(Schema.SObjectField field: BlackListFields.values()) {
                if(data == field.getDescribe().getName()){
                    if(data.contains(field.getDescribe().getName())){
                        table.childComponents.add(addColumns(field, type));
                    }
                }
            }
        }
        return table;
    }

    private Component.Apex.Column addNumberColumn(){
        Component.Apex.Column column_no = new Component.Apex.Column();
        Component.Apex.OutputText output_text = new Component.Apex.OutputText();
        output_text.expressions.value = '{!WrapMap[BlacklistRecord.Id].ColumnNo}';
        column_no.childComponents.add(output_text);
        column_no.headerValue = 'No';
        return column_no;
    }

    private Component.Apex.Column addColumns(Schema.SObjectField field ,String type){
        Component.Apex.OutputField output_field = new Component.Apex.OutputField();
        output_field.expressions.value = '{!BlacklistRecord.' + field.getDescribe().getName() + '}';
        Component.Apex.CommandLink header = new Component.Apex.CommandLink();
        header.value = field.getDescribe().getLabel() + (SortOrder ? '▴' : '▾');
        if(type == 'removed'){
            header.onclick = '{!sortRemovedColumn(event.target.innerHTML)}';
        }
        else if(type == 'current'){
            header.onclick = '{!sortCurrentColumn(event.target.innerHTML)}';
        }
        header.reRender = new Set<String>{'none'};
        return setColumn(header, output_field);
    }

    private Component.Apex.Column setColumn(Component.Apex.CommandLink header, Component.Apex.OutputField output_field){
        Component.Apex.Column column = new Component.Apex.Column();
        column.facets.header = header;
        column.expressions.lang = '{!BlacklistRecord.Id}';
        column.onclick = 'sendParam(this.lang)';
        column.childComponents.add(output_field);
        return column;
    }

    public List<Blacklist__c> getRemovedRecordsToShow(){
        return AllBlacklistRemovedSet.getRecords();
    }

    public List<Blacklist__c> getCurrentRecordsToShow(){
        return AllBlacklistCurrentSet.getRecords();
    }

    public void selectedBlackListRecord(){
        BlacklistRecord = Database.query(BLACKLIST_QUERY_BASE + ' FROM Blacklist__c WHERE Id =  \'' + IdBlackListRecord + '\'');
    }

    public void selectedFields(){
        FieldsToShow.clear();
        FieldsToShow.addAll(SelectedFieldsToShow);
        AllBlacklistCurrentSet.setPageSize(BlacklistPerPage);
        AllBlacklistRemovedSet.setPageSize(BlacklistPerPage);
    }

    public void sortCurrentRecordColumn(){
        String query = BLACKLIST_QUERY_BASE + ' FROM Blacklist__c WHERE Removed_Date__c = null ORDER BY '+ findColumnToSort() + ' '+getOrder();
        List<Blacklist__c> blacklist_current_records = executeBlacklistQuery(query);
        uploadNoColumnValues(blacklist_current_records);
        AllBlacklistCurrentSet = new ApexPages.StandardSetController(blacklist_current_records);
        AllBlacklistCurrentSet.setPageSize(BlacklistPerPage);
    }

    public void sortRemovedRecordColumn(){
        String query = BLACKLIST_QUERY_BASE + ', Removed_Date__c,Removed_by_User__c FROM Blacklist__c WHERE Removed_Date__c != null ORDER BY '+ findColumnToSort() + ' '+getOrder();
        List<Blacklist__c> blacklist_removed_records = executeBlacklistQuery(query);
        uploadNoColumnValues(blacklist_removed_records);
        AllBlacklistRemovedSet = new ApexPages.StandardSetController(blacklist_removed_records);
        AllBlacklistRemovedSet.setPageSize(BlacklistPerPage);
    }

    private String findColumnToSort(){
        String column_name;
        for(Schema.SObjectField field: BlackListFields.values()) {
            if(ColumnToSort.contains(field.getDescribe().getLabel())){
                column_name = field.getDescribe().getName();
            }
        }
        return column_name;
    }

    @TestVisible
    private List<Blacklist__c> executeBlacklistQuery(String query){
        List<Blacklist__c> blacklist = new List<Blacklist__c>();
        try{
           blacklist = Database.query(query);
        }
        catch(QueryException e){
            InfoMessage.showError('Ooops, something appears to have gone wrong. Please try and refresh the page or if the problem continues, raise a ticket and include a screenshot. ' + e.getMessage());
        }
        return blacklist;
    }

    private void uploadNoColumnValues(List<Blacklist__c> blacklist_list){
        Integer column_no = 1;
        for (Blacklist__c blacklist :blacklist_list){
            WrapMap.put(blacklist.id, new WrapBlacklist(column_no));
            column_no++;
        }
    }

    private String getOrder(){
        if(SortOrder){
            SortOrder = false;
            return 'ASC';
        }
        SortOrder = true;
        return 'DESC';
    }

    public void showAddBlacklistPanel(){
        InfoMessage = new MessageUtility();
        ShowRemoveBlacklist = false;
        ShowAddBlacklist = true;
    }

    public void showRemoveBlacklistPanel(){
        ShowRemoveBlacklist = true;
        ShowAddBlacklist = false;
    }

    public void showApproveSection(){
        ShowApproveSection = true;
        BlacklistRecord = BlacklistNewRecord;
        ShowRemoveBlacklist = true;
        ShowAddBlacklist = false;
    }

    public void confirmAction(){
        InfoMessage.hide();
        if(sendAddBlacklistRecord()){
            ShowApproveSection = false;
            ShowRemoveBlacklist = true;
            BlacklistRecord = new Blacklist__c();
            BlacklistNewRecord = new Blacklist__c();
            ShowAddBlacklist = false;
        }
    }

    private Boolean sendAddBlacklistRecord(){
        Config = CsApiConfig.getBuilder(CsApiTypes.Market.PL).setProduct(CsApiTypes.Product.LittleLoan).build();
        CsApi api;
        try{
            api = CsApi.getApi(Config);
        }
        catch(Exception e){
            CsApiExceptionsHandler result = CsApiExceptionsHandler.handle(e);
            ApexPages.addMessage(result.message);
            return false;
        }
        return sendAddBlacklist(api);
    }

    private Boolean sendAddBlacklist(CsApi api){
        if(api != null){
            CsApiObjects.Reply result = sendAddBlacklistCommand(api);
            if (result.Error == null){
                InfoMessage.showConfirm('Add to Blacklist successfully');
                return true;
            }
            else {
                InfoMessage.showError(result.Error);
                return false;
            }
        }
        return false;
    }

    private CsApiObjects.Reply sendAddBlacklistCommand(CsApi api){
            IImplementCsApiMethod add_blacklist = CsApiMethodFactory.getMethod('CsApiCommandAddBlacklist', Config);
            setBlackListFieldsMapToSendToBE();
            if(BlacklistNewRecord.Type__c == 'Full Match'){
               add_blacklist.setMethodInput('Type','FullMatch');
            }
            else if(BlacklistNewRecord.Type__c == 'Partial Match'){
                add_blacklist.setMethodInput('Type','PartialMatch');
            }
            for(String field_key : BlacklistFieldsMap.keySet()){
                if(BlacklistFieldsMap.get(field_key) != null){
                    add_blacklist.setMethodInput(field_key,BlacklistFieldsMap.get(field_key));
                }
            }
            api.addMethod(add_blacklist);
            api.send();
        return api.getResponse(add_blacklist);
    }

    private void setBlackListFieldsMapToSendToBE(){
        BlacklistFieldsMap = new Map<String,String>
                                            {
                                                'FirstName' => BlacklistNewRecord.First_name__c,
                                                'LastName' => BlacklistNewRecord.Last_name__c,
                                                'PostCode' => BlacklistNewRecord.Post_Code_Official__c,
                                                'HomePhone' => BlacklistNewRecord.Home_Phone__c,
                                                'MobilePhone' => BlacklistNewRecord.Mobile_Phone__c,
                                                'WorkPhone' => BlacklistNewRecord.Work_phone__c,
                                                'EmployerName' => BlacklistNewRecord.Employers_name__c,
                                                'CardNumber' => BlacklistNewRecord.Card_Number__c,
                                                'BankAccount' => BlacklistNewRecord.Bank_Account__c,
                                                'SortCode' => BlacklistNewRecord.Sort_Code__c,
                                                'Email' => BlacklistNewRecord.Email__c,
                                                'PeselNumber' => BlacklistNewRecord.PESEL__c,
                                                'IdentificationDocumentId' => BlacklistNewRecord.Id_Document_Number__c,
                                                'MiddleName' => BlacklistNewRecord.Middle_name__c,
                                                'MaidenName' => BlacklistNewRecord.Mothers_Maiden_Name__c,
                                                'CityOfficial' => BlacklistNewRecord.City_Official__c,
                                                'StreetOfficial' => BlacklistNewRecord.Street_Official__c,
                                                'HouseNumberOfficial' => String.valueOf(BlacklistNewRecord.House_Number_Official__c),
                                                'FlatNumberOfficial' => String.valueOf(BlacklistNewRecord.Flat_Number_Official__c),
                                                'CityResedential' => BlacklistNewRecord.City_Residential__c,
                                                'StreetResedential' => BlacklistNewRecord.Street_Residential__c,
                                                'HouseNumberResedential' => String.valueOf(BlacklistNewRecord.House_Number_Residential__c),
                                                'FlatNumberResedential' => String.valueOf(BlacklistNewRecord.Flat_Number_Residential__c)
                                            };
    }

    public void cancelConfirmation(){
        InfoMessage.hide();
        ShowApproveSection = false;
        ShowRemoveBlacklist = false;
        BlacklistRecord = new Blacklist__c();
        ShowAddBlacklist = true;

    }

    public class WrapBlacklist{

        public Integer ColumnNo {get; set;}
        public WrapBlacklist(Integer column_no){
            ColumnNo = column_no;
       }
    }


}