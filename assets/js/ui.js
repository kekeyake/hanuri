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
    $('.depth1 li').hover(function(){
        $(this).addClass('on').siblings('li').removeClass('on');
    }).mouseleave(function(){
        $('.depth1 li').removeClass('on');
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
                return attr.replace('_hide.png', '.png');
            } else {
                return attr.replace('.png', '_hide.png');
            }
        });
    });

    $('.setting_ly .btn_box button').on('click',function(){
        $(this).addClass('on').siblings('button').removeClass('on');
    });

    $('.tab_container .tab_cont').hide();
    $('.tab_container .tab_cont.introduction').show();
    $('#courseTab button').on('click',function(){
        $(this).addClass('on').siblings('button').removeClass('on');
        var tabLink = $(this).attr('data-rel');
        $('.tab_container .tab_cont').hide();
        $('.tab_container .tab_cont.'+tabLink+'').show();

    });

    $('.tab_cont.study .tit').on('click',function(){
        $(this).toggleClass('on').next('ol').toggleClass('on');
    });

    $('.course .agree_wrap .tit').on('click',function(){
        $(this).next('.info_box').toggleClass('on');
    });

    $('.btn_sort').on('click',function(){
        $('.bg_dimmed').addClass('on');
        $('.setting_ly').addClass('on');
        
    });

    $('.btn_recommend').on('click',function(){
        $('.bg_dimmed').addClass('on');
        $('.__recommend').addClass('on');
        // $('.view_ly').addClass('on');
        
    });

    $('.btn_setting_closed').on('click',function(){
        $('.bg_dimmed').removeClass('on');
        $('.__layer').removeClass('on');
        
    });
    $('.btn_sort_list .category').on('click',function(){
        $(this).addClass('on').siblings('.category').removeClass('on');
    });

    $('.info_wrap .btn').on('click',function(){
        $(this).addClass('on').siblings('.btn').removeClass('on');
    });

    var thisUrl = window.location.href;
    var tabActive = thisUrl.slice(-3);
    switch (tabActive) {
        case "F05":
            $('.nav_menu li.n2').addClass('on').siblings('li').remoeClass('on');
            break;
        case "F04":
            $('.nav_menu li.n3').addClass('on').siblings('li').remoeClass('on');
            break;
        case "F03":
            $('.nav_menu li.n4').addClass('on').siblings('li').remoeClass('on');
            break;
        case "F01":
            $('.nav_menu li.n5').addClass('on').siblings('li').remoeClass('on');
            break;
        case "F06":
            $('.nav_menu li.n8').addClass('on').siblings('li').remoeClass('on');
            break;
        default:
            break;
    }

    $('.tool_tip').on('click',function(){
        var tg = $(this).attr('data-rel');
        $('.' + tg).addClass('on');
        console.log(tg);
    });
    $('.btn_closed_tooltip').on('click',function(){
        $(this).parent('.tool_layer').removeClass('on');
    });
    
});

