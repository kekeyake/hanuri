var $winW, $winH, $isMobile, $headerHeight;
$(function () {
    $headerHeight = $('header.header').innerHeight();
    // ===== Scroll to Top ==== 
    $(window).scroll(function () {
        if ($(window).scrollTop() > $headerHeight) {
            $('.pc_menu').addClass('sticky');
        } else {
            $('.pc_menu').removeClass('sticky');
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

