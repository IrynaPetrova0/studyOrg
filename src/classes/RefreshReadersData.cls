global with sharing class RefreshReadersData {

    @AuraEnabled
    public static void makeGetCallout(Id myTest) {
        System.debug('Success');
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://avenga-school.herokuapp.com/retrieve-record');
        request.setMethod('GET');
        request.setHeader('objectName', 'Reader');
        request.setHeader('recordId', myTest);
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 200) {
            // Deserializes the JSON string into collections of primitive data types.
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            // Cast the values in the 'reader' key as a list
            Object reader = (Object) results;
            System.debug('Received the following reader:');
            System.debug(reader);

            Reader__c updateReader = new Reader__c();
            updateReader.Id = (String)results.get('recordId');
            updateReader.Name = (String)results.get('name');
            updateReader.Email__c = (String) results.get('email');
            updateReader.Debtor__c = (Boolean) results.get('debtor');
            updateReader.Subscription_Type__c = (String) results.get('subscriptionType');
            updateReader.Last_Sync_Date__c = Datetime.now();
            System.debug(updateReader);

            try{
                update updateReader;
            }catch(DmlException e){
                System.debug(e.getMessage());
                //System.debug('');
            }

        }

        //return response;

    }
}