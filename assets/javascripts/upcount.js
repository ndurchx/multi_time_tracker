var time_td = Document.getElementById('active_time_logging');
var seconds;
var mintes;
var hours;
var days;


function loop() {
 
  seconds++;
  if (seconds >= 60)
  {
    seconds -= 60;
    minutes++;
  {
  if (minutes >= 60)
  {
    minutes -= 60;
    hours++;
  }
  if (hours >= 24)
  {
    if (days == null)
    {
      days = 1;
    }
    else
    {
      days++;
    }
    hours -= 24;
  }
  
  if (days == null)
  {
    time_td.firstChild.data = hours+":"+minutes+":"+seconds;
  }
  else
  {
    time_td.firstChild.data = days+":"+hours+":"+minutes+":"+seconds
  }
  
  setTimeout('1000');

}


function startLoop() {
  
  var arrValues = time_td.firstChild.data.split(":");
  seconds = arrValues[0];
  minutes = arrValues[1];
  hours = arrValues[2];
  if (arrValues.length > 3)
  {
    days = arrValues[3];
  }
  
  loop();
  
}
