var $winW, $winH, $isMobile, $headerHeight;
$(function () {
    $headerHeight = $('.header').innerHeight();
    // ===== Scroll to Top ==== 
    $(window).scroll(function () {
        if ($(window).scrollTop() > 106) {
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
    $('.depth1 > ul').hover(function(){
        subUp();
    });
    $('.pc_menu').mouseleave(function(){
        subDown();
    });

    function subUp() {
        $('.pc_sub_menu').slideDown();
    }
    function subDown() {
        $('.pc_sub_menu').slideUp();
    }
});

