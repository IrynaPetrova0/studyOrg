public class Utils {
   public static Map<String, List<sObject>> groupRecordsByField(List<sObject> recordsToBeGrouped, String groupByField){
       Map<String, List<sObject>> resMap = new Map<String, List<sObject>>();
       Set<String> values = new Set<String>();
       
       for(sObject rec: recordsToBeGrouped){
           values.add(String.valueOf(rec.get(groupByField)).toLowerCase());
       }
       
       List<sObject> tempList = new List<sObject>();
       
       for(String recS: values){
           for(Integer j = 0; j < recordsToBeGrouped.size(); j++){
               String listString = String.valueOf(recordsToBeGrouped.get(j).get(groupByField));
               if(recS.equalsIgnoreCase(listString)){                  
                   tempList.add(recordsToBeGrouped.get(j));
               }
           }
           resMap.put(recS, tempList.clone());
           tempList.clear();
       }
              
       return resMap;
    }
    
    public static Set<String> getFieldValueFromSobjectList(List<sObject> dataList, String fieldApiName){
        Set<String> resSet = new Set<String>();
        
        for(sObject obj: dataList){
            if(obj.get(fieldApiName) != null){
                resSet.add((String)obj.get(fieldApiName));
            }
        }
        return resSet;
    } 
}