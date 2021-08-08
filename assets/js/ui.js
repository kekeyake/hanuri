var $winW, $winH, $isMobile, $headerHeight;

$(function () {
    $headerHeight = $('.header').innerHeight();

    // ===== Scroll to Top ==== 
    $(window).scroll(function () {
        if ($(window).scrollTop() > 106) {
            $('.pc_menu').addClass('sticky');
            $('h1.h1').addClass('sticky');
        } else {
            $('.pc_menu').removeClass('sticky');
            $('h1.h1').removeClass('sticky');
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
    // $('.depth1 > ul').hover(function(){
    //     subUp();
    // });
    $('.depth1 li').hover(function(){
        $(this).addClass('on').siblings('li').removeClass('on');
    }).mouseleave(function(){
        $('.depth1 li').removeClass('on');
    });
    $('.pc_menu').mouseenter(function(){
        subUp();
    });
    $('.pc_menu').mouseleave(function(){
        subDown();
    });

    function subUp() {
        $('.pc_sub_menu').stop().slideDown();
    }
    function subDown() {
        $('.pc_sub_menu').stop().slideUp();
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
        // console.log($(document).height());
        
        // function resize(){  
        //     var resizeHeight = $('#content').height();
        //     $("#iframeWin",parent.document).height( resizeHeight + 150 );
        // });          
        $(this).addClass('on').siblings('button').removeClass('on');
        var tabLink = $(this).attr('data-rel');
        $('.tab_container .tab_cont').hide();
        $('.tab_container .tab_cont.'+tabLink+'').show();
        var resizeHeight = $('.tab_container').height();
        $("#info_tab",parent.document).height( resizeHeight + 150);

    });

    $('.tab_cont.study .tit').on('click',function(){
        $(this).toggleClass('on').nextUntil('.tit').toggleClass('on');
        var resizeHeight = $('.tab_container').height();
        $("#info_tab",parent.document).height( resizeHeight + 150);
    });

    $('.agree_wrap .tit').on('click',function(){
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

    $('.btn_member').on('click',function(){
        $('.bg_dimmed').addClass('on');
        $('.__member').addClass('on');
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
    });
    $('.btn_closed_tooltip').on('click',function(){
        $(this).parent('.tool_layer').removeClass('on');
    });
    

    $('.status_info .info_txt').on('click', function(){
        $('.bg_dimmed').addClass('on');
        $('.survey_ly').addClass('on');
    });
    $('.survey_ly .btn_wrap button').on('click', function(){
        $('.bg_dimmed').removeClass('on');
        $('.__layer').removeClass('on');
    });

    $('.inflow_list button').on('click', function(){
        $(this).toggleClass('on');
    });

    $('.btn_review').on('click', function(){
        $('.bg_dimmed').addClass('on');
        $('.evaluating_courses_ly').addClass('on');
    });

    // $('.list_tab .link').on('click',function(){
    //     var tg = $(this).attr('data-rel');
    //     $(this).addClass('on').siblings('.link').removeClass('on');
    //     $('#' + tg).addClass('on').siblings('.tab_cont').removeClass('on');
    // });

    $('.add_file').each(function (index, item) { 
        $(this).on('change' ,function(){
            var fileValue = $(this).val().split("\\");
            var fileName = fileValue[fileValue.length-1]; // 파일명    
            $(this).closest('div').find('.attachName').val(fileName);
            console.log(fileName);
        });

    });   
    if ($('.notice_swiper').length) {
        var swiper = new Swiper(".notice_swiper", {
            direction: "vertical",
            loop: true,
            spaceBetween: 10,
            autoplay: {
                delay : 3500,
            },
        });
    }    
    $('.check_point_box .check_star li').on('click',function(){
        var idx = $(this).index()+1;
        var pointTxt = $(this).closest('.check_point_box').find('.pointTxt');
        $(this).parent('ul').find('li').removeClass('on');
        $(this).parent('ul').find('li:lt('+ idx +')').addClass('on');
        pointTxt.addClass('on');
        $(this).parent('ul').next('.infoTxt').hide();
        switch (idx) {
            case 1 :
                pointTxt.text("1점 : 매우 미흡");
                break;
            case 2 :
                pointTxt.text("2점 : 미흡");
                break;
            case 3 :
                pointTxt.text("3점 : 보통");
                break;
            case 4 :
                pointTxt.text("4점 : 우수");
                break;
            case 5 :
                pointTxt.text("5점 : 매우 우수");
                break;
        }
        //console.log(idx);
    });

    $('.apply_refund a').on('click',function (){
        $(this).addClass('on').parent('li').siblings('li').find('a').removeClass('on');
    });

    if ( $('.top_banner_slide').length ) {
        var mainSwiper1 = new Swiper(".top_banner_slide", {
            slidesPerView:1,
            loop: true,
            effect: "fade",
            speed:1000,
            autoplay: {
                delay : 3500,
                disableOnInteraction: false,
            },
            pagination: {
                el: ".top_banner_slide .swiper-pagination",
            },
        });
    }
    if ( $('.interview_slide').length ) {
        var mainSwiper2 = new Swiper(".interview_slide", {
            slidesPerView:1,
            loop: true,
            autoplay: {
                delay : 3500,
                disableOnInteraction: false,
            },
            navigation: {
                nextEl: ".interview_slide .swiper-button-next",
                prevEl: ".interview_slide .swiper-button-prev",
            },
        });
        
    }

    if ($('.reply_list').length) {
        var mainSwiper3 = new Swiper(".reply_list", {
            slidesPerView:3,
            direction: "vertical",
            loop: true,
            touchRatio: 0,//드래그 금지
            speed:700,
            autoHeight : true,
            autoplay: {
                delay : 3500,
                disableOnInteraction: false,
            },
        });
    }    
    
    if ( $('.event_banner_slide').length ) {
        var mainSwiper4 = new Swiper(".event_banner_slide", {
            loop: true,
            autoplay: {
                delay : 3500,
                disableOnInteraction: false,
            },
            pagination: {
                el: ".event_banner .swiper-pagination",
            },
            navigation: {
                nextEl: ".event_banner_slide .swiper-button-next",
                prevEl: ".event_banner_slide .swiper-button-prev",
            },
            breakpoints: {
                1200: {
                    slidesPerView: 2,
                    spaceBetween: 20,                    
                },
            },
        });
    }
});
var ww = $(window).width();
var mainSwiper5 = undefined;
function initSwiper() {

    if (ww < 1280 && mainSwiper5 == undefined) {
        mainSwiper5 = new Swiper(".__notice_list .swiper-container", {
            direction: "vertical",
            loop: true,
            autoplay: {
                delay : 3500,
            },
        });
    } else if (ww > 1279 && mainSwiper5 != undefined) {
        mainSwiper5.destroy();
        mainSwiper5 = undefined;
    }
}

initSwiper();

$(window).on('resize', function () {
    ww = $(window).width();
    initSwiper();
});

    


