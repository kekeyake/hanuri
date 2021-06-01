var $winW, $winH, $isMobile;
$(function () {

    chkBrowserSize();
    $(window).resize(function () {
        chkBrowserSize();
    });

    // ===== Scroll to Top ==== 
    $(window).scroll(function () {
        if ($(window).scrollTop() > 100) {
            $('header').addClass('sticky');
        } else {
            $('header').removeClass('sticky')
        }
    });
});

function chkBrowserSize() {
    $winW = $(window).width();
    $winH = $(window).height();

    if ($winW < 1025) {
        $isMobile = true;
    } else {
        $isMobile = false;
    }
}