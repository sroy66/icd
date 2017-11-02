var hdd = $('.storage-progress.circle-progress');
var mem = $('.memory-progress.circle-progress');
var cpu = $('.cpu-progress.circle-progress');

hdd.circleProgress({
  value: 0.0,
  animation: true,
  thickness: 10,
  fill: {
    gradient: ['#ff1e41', '#ff5f43']
  }
}).on('circle-animation-progress', function(event, progress) {
  $(this).find('strong').html(Math.round(100 * $(this).circleProgress('value')) + '<i>%</i>');
});

mem.circleProgress({
  value: 0.0,
  animation: true,
  thickness: 10,
  fill: {
    gradient: ['#ff1e41', '#ff5f43']
  }
}).on('circle-animation-progress', function(event, progress) {
  $(this).find('strong').html(Math.round(100 * mem.circleProgress('value')) + '<i>%</i>');
});

cpu.circleProgress({
  value: 0.0,
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
    //hdd.circleProgress('value', Math.random());
    //mem.circleProgress('value', Math.random());
    //cpu.circleProgress('value', Math.random());
    //setTimeout(function() {
    //  refresh();
    //}, interval);

    $.get('api/perf', function(perf) {
      hdd.circleProgress('value', perf.hdd.value);
      mem.circleProgress('value', perf.mem.value);
      cpu.circleProgress('value', perf.cpu.value);
      setTimeout(function() {
        refresh();
      }, interval);
    }, 'json');
  };
  refresh();
});
