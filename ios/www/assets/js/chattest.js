function ruralroad() {
  if(document.getElementById('ruralroaddiv')==null){
    return;
  }
  var myChart = echarts.init(document.getElementById('ruralroaddiv'));
  var option = {
    tooltip: {
      trigger: 'axis'
    },
    legend: {
      data: ['2011年', '2012年']
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'value',
      boundaryGap: [0, 0.01]
    },
    yAxis: {
      type: 'category',
      data: ['竣工','交工','完工','在建','未开工']
    },
    series: [
      {
        name: '2017年',
        type: 'bar',
        data: [ 0, 0, 1805, 766, 145]
      }
    ]
  };
  myChart.setOption(option);
}
function xmlToJson(xml) {
  // Create the return object
  var obj = {};
  if (xml.nodeType == 1) { // element
    // do attributes
    if (xml.attributes.length > 0) {
      obj["@attributes"] = {};
      for (var j = 0; j < xml.attributes.length; j++) {
        var attribute = xml.attributes.item(j);
        obj["@attributes"][attribute.nodeName] = attribute.nodeValue;
      }
    }
  } else if (xml.nodeType == 3) { // text
    obj = xml.nodeValue;
  }
  // do children
  if (xml.hasChildNodes()) {
    for(var i = 0; i < xml.childNodes.length; i++) {
      var item = xml.childNodes.item(i);
      var nodeName = item.nodeName;
      if (typeof(obj[nodeName]) == "undefined") {
        obj[nodeName] = xmlToJson(item);
      } else {
        if (typeof(obj[nodeName].length) == "undefined") {
          var old = obj[nodeName];
          obj[nodeName] = [];
          obj[nodeName].push(old);
        }
        obj[nodeName].push(xmlToJson(item));
      }
    }
  }
  return obj;
};
function test() {
  var parser = require('xml2json');
}

