## Get the model from an interactive grid

```
var widget = apex.region('transaction_lines').widget();
var model = widget.interactiveGrid('getViews','grid').model;
```

## Get the number of rows in a grid

```
apex.debug("records=" + model.getTotalRecords());
```

## Copy a value to each row in a grid

```
model.forEach(function(r) {
  model.setValue(r,'LINE_AMT',amt);
  });
}
```

## Get the first row in a grid

```
var rec = model.recordAt(0);
```

## Parse a JSON fragment and populate a grid

```
var arr = JSON.parse($v("P1_JSON"));
if (arr.length > 0) {
    var myNewRecord;
    model.clearData();
    for(i=0; i<arr.length; i++) {
      //insert new record on a model
      var myNewRecordId = model.insertNewRecord(undefined, myNewRecord);
      //get the new record
      myNewRecord = model.getRecord(myNewRecordId);
      //update record values
      model.setValue(myNewRecord, 'QUANTITY', arr[i].quantity);
      model.setValue(myNewRecord, 'PER_ITEM_AMT', arr[i].per_item_amt);
      model.setValue(myNewRecord, 'LINE_AMT', arr[i].line_amt);
      model.setValue(myNewRecord, 'MEMO', arr[i].memo);
    }
}
```
