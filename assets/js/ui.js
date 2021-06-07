var $winW, $winH, $isMobile;
$(function () {
    // ===== Scroll to Top ==== 
    $(window).scroll(function () {
        if ($(window).scrollTop() > 100) {
            // $('header').addClass('sticky');
            // $('.main').addClass('sticky');
        } else {
            // $('header').removeClass('sticky')
            // $('.main').removeClass('sticky');
        }
    });

    $("#btnMobile").off().on('click',function(){
        $('.side_nav').addClass('open');
    });
    $("#btnClosed").off().on('click',function(){
        $('.side_nav').removeClass('open');
    });

    $('.question').on('click',function(){
        $(this).next('.answer').toggleClass('open');
    });
});

