({
    fetchBookHelper : function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'Book Name', fieldName: 'Name', type: 'text'},
            {label: 'Author', fieldName: 'Author__c', type: 'text'}
        ]);
        var action = component.get("c.fetchBooks");
        action.setParams({
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.acctList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})