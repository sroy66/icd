var hdd = $('.storage-progress.circle-progress');
var ram = $('.memory-progress.circle-progress');
var cpu = $('.cpu-progress.circle-progress');

hdd.circleProgress({
  value: 0.25,
  animation: true,
  thickness: 10,
  fill: {
    gradient: ['#ff1e41', '#ff5f43']
  }
}).on('circle-animation-progress', function(event, progress) {
  $(this).find('strong').html(Math.round(100 * $(this).circleProgress('value')) + '<i>%</i>');
});

ram.circleProgress({
  value: 0.5,
  animation: true,
  thickness: 10,
  fill: {
    gradient: ['#ff1e41', '#ff5f43']
  }
}).on('circle-animation-progress', function(event, progress) {
  $(this).find('strong').html(Math.round(100 * ram.circleProgress('value')) + '<i>%</i>');
});

cpu.circleProgress({
  value: 0.75,
  animation: true,
  thickness: 10,
  fill: {
    gradient: ['#ff1e41', '#ff5f43']
  }
}).on('circle-animation-progress', function(event, progress) {
  $(this).find('strong').html(Math.round(100 * cpu.circleProgress('value')) + '<i>%</i>');
});

$(document).ready(function() {
  // TODO put this into the template (?)
  $('nav li').removeClass('active');
  $('#home').addClass('active');

  var interval = 1000;
  var refresh = function() {
    hdd.circleProgress('value', Math.random());
    ram.circleProgress('value', Math.random());
    cpu.circleProgress('value', Math.random());
    setTimeout(function() {
      refresh();
    }, interval);

    $.get('api/perf/', function(perf) {
      hdd.circleProgress('value', perf.hdd.value);
      ram.circleProgress('value', perf.ram.value);
      cpu.circleProgress('value', perf.cpu.value);
      setTimeout(function() {
        refresh();
      }, interval);
    }, 'json');
  };
  refresh();
});
