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

    $('.btn_toggle').on('click',function(e){
        var $this = $(this).find('img');
        var $prevInput = $(this).prev();
        if ( $this.attr('src').match('_hide') ) {
            $(this).prev().attr('type','password');
        } else {
            $(this).prev().attr('type','text');
        }
        $this.attr('src', function(index, attr){
            if ( attr.match('_hide')){
                return attr.replace('_hide.svg', '.svg');
            } else {
                return attr.replace('.svg', '_hide.svg');
            }
        });
    });
});

