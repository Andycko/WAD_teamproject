$( document ).ready(function() {
   $('#login_link').click(function() {
       $('#login_wrap').addClass('active');
    });
    
    $('#close_login').click(function() {
        $('#login_wrap').removeClass('active');
    });
    
    if ( $('#login_wrap').hasClass('false') ){
        $('#login_wrap').addClass('active');
    } else if ( $('#login_wrap').hasClass('true') ){
        $('#login_wrap').removeClass('active');        
    }
    
    $("#register_btn").click(function() {
        $(".row").addClass("register")
    });

    $("#login_btn").click(function() {
        $(".row").removeClass("register")
    });

    $('a').each(function(){
        if ($(this).prop('href') == window.location.href) {
            $(this).addClass('active'); $(this).parents('li').addClass('active');
        }
    });

    $('#edit_area').each(function() {
        this.style.height = 'auto'; 
        this.style.height = (this.scrollHeight) + 'px'; 
    }); 

    $('#edit_area').on('input', function () { 
        this.style.height = 'auto';   
        this.style.height = (this.scrollHeight) + 'px'; 
    }); 
});