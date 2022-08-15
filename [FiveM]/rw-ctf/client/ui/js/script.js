$(function() {
    window.addEventListener('message', function(event) {
        let data = event.data

        if (data.action === "showMenu") {
            $('.container').show();
        } else if (data.action === "hideMenu") {
            $('.container').hide();
        } else if (data.action === "updateData") {
            if (data.controllers) {
                $('#controller-a').text('Kontrollib: ' + data.controllers.a);
                $('#controller-b').text('Kontrollib: ' + data.controllers.b);
                $('#controller-c').text('Kontrollib: ' + data.controllers.c);
            }
        }
    });
});