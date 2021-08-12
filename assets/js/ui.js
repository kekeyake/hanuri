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
    $('.__top').on('click',function() {        
        $("html, body").animate({ scrollTop: 0 },500);
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
    // $('.depth1 li').hover(function(){
    //     $(this).addClass('on').siblings('li').removeClass('on');
    // }).mouseleave(function(){
    //     $('.depth1 li').removeClass('on');
    // });
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
            $(this).prev().attr('type','text');
        } else {
            $(this).prev().attr('type','password');
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
    var tabActive = thisUrl.slice(-2);
    switch (tabActive) {
        case "S1":
            $('.nav_menu li').eq(0).addClass('on').siblings('li').removeClass('on');
            break;
        case "S2":
            $('.nav_menu li').eq(1).addClass('on').siblings('li').removeClass('on');
            break;
        case "S3":
            $('.nav_menu li').eq(2).addClass('on').siblings('li').removeClass('on');
            break;
        case "S4":
            $('.nav_menu li').eq(3).addClass('on').siblings('li').removeClass('on');
            break;
        case "S5":
            $('.nav_menu li').eq(4).addClass('on').siblings('li').removeClass('on');
            break;
        case "S6":
            $('.nav_menu li').eq(5).addClass('on').siblings('li').removeClass('on');
            break;
        case "S7":
            $('.nav_menu li').eq(6).addClass('on').siblings('li').removeClass('on');
            break;
        case "S8":
            $('.nav_menu li').eq(7).addClass('on').siblings('li').removeClass('on');
            break;
        default:
            break;
    }

    var thisPageUrl = window.location.href;
    var sortActive = thisPageUrl.slice(-2);
    switch (sortActive) {
        case "C1":                        
            $('.btn_sort_list .n1').addClass('on').siblings('button').removeClass('on');
            break;
        case "C2":
            $('.btn_sort_list .n2').addClass('on').siblings('button').removeClass('on');
            break;
        case "C3":
            $('.btn_sort_list .n3').addClass('on').siblings('button').removeClass('on');
            break;
        case "C4":
            $('.btn_sort_list .n4').addClass('on').siblings('button').removeClass('on');
            break;                    
        default:
            break;
    }
    // $('.btn_sort_list .category').on('click',function(){                
    //     $(this).addClass('on').siblings('.category').removeClass('on');
    // });

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
        $(this).closest('.check_point_box').find('input[type=hidden]').val(idx);
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
                clickable: true,
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
            speed:700,
            autoHeight : true,
            allowTouchMove: false,
            autoplay: {
                delay : 3500,
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
                clickable: true,
            },
            navigation: {
                nextEl: ".event_banner .swiper-button-next",
                prevEl: ".event_banner .swiper-button-prev",
            },
            breakpoints: {
                1200: {
                    slidesPerView: 2,
                    spaceBetween: 20,                    
                },
            },
        });
    }

    if ( $('.dont_slide01').length ) {
        var introSwiper1 = new Swiper(".dont_slide01", {            
            centeredSlides: true,
            slidesPerView: "auto",
            spaceBetween: 25,
            loop: true,
            centeredSlides: true,

            // autoplay: {
            //     delay : 3500,
            //     disableOnInteraction: false,
            // },
            pagination: {
                el: ".dont_slide01 .swiper-pagination",
                clickable: true,
            },
        });
            
    }

    if ( $('.dont_slide02').length ) {
        var introSwiper2 = new Swiper(".dont_slide02", {
            slidesPerView: "auto",
            centeredSlides: true,
            spaceBetween: 25,
            loop: true,
            centeredSlides: true,

            // autoplay: {
            //     delay : 3500,
            //     disableOnInteraction: false,
            // },
            pagination: {
                el: ".dont_slide02 .swiper-pagination",
                clickable: true,
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

    


