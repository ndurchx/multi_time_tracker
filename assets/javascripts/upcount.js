var time_td;
var seconds;
var mintes;
var hours;
var days;

function formatOutput (days, hours, minutes, seconds) 
{
  var ret = "";
  
  if (days != null)
  {
    ret = "" + days + ":";
  }
  
  if (hours < 10)
  {
    ret += "0"+hours;
  }
  else
  {
    ret += hours;
  }
  
  ret += ":";
  
  if (minutes < 10)
  {
    ret += "0" + minutes;
  }
  else
  {
    ret += minutes;
  }
  
  ret += ":";
  
  if (seconds < 10)
  {
    ret += "0" + seconds;
  }
  else 
  {
    ret += seconds;
  }
  
  return ret;
  
}


function loop () 
{
 
  seconds ++;
  
  if (seconds >= 60)
  {
    seconds -= 60;
    minutes ++;
  }
  if (minutes >= 60)
  {
    minutes -= 60;
    hours ++;
  }
  if (hours >= 24)
  {
    if (days == null)
    {
      days = 1;
    }
    else
    {
      days ++;
    }
    hours -= 24;
  }
  
  time_td.firstChild.data = formatOutput(days, hours, minutes, seconds);
  
  setTimeout('loop()', 1000);

}


function startLoop () 
{
  
  var arrValues;
  time_td = document.getElementById('active_time_logging');
  
  if (time_td != null)
  {
    arrValues = time_td.firstChild.data.split(":");
    seconds   = arrValues[2].replace(/^0/, '');
    minutes   = arrValues[1].replace(/^0/, '');
    hours     = arrValues[0].replace(/^0/, '');
    
    if (arrValues.length > 3)
    {
      days = arrValues[3];
    }
    
    loop();
  }
  
}
