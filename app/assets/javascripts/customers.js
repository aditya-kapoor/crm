$('document').ready(function(){
  $('#checkall').live("click", function(){
    $('input:checkbox').attr('checked', this.checked)
  })
  $('.export-csv').live("click", function(){
    if ($('input:checkbox[name="customer_ids[]"]:checked').length == 0) {
      alert('Please make atleast one selection')
      event.preventDefault();
    }
  })
})

var global_data = []
var search_string = ""
function get_results(){
  search_string = $('#search_term').val()
  get_data(search_string)
}

function get_data(search_string) {
  $.ajax({
    url: "/customers/get_results?search_string="+search_string,
    dataType : "json",
    success: function(data){
      global_data = data
      setSearchResults(global_data)
    }
  });
}

function setSearchResults(global_data) {
  $form = $('<form />')
  $form.attr("action", "/customers/export_to_csv")
  $form.attr("method", "post")

  $checkall_box = $('<input />')
  $checkall_box.attr("type", "checkbox")
  $checkall_box.attr("id", "checkall")
  $checkall_box.attr("name", "checkall")
  $checkall_box.attr("value", "1")

  $checkbox_header = $('<th />')
  $checkbox_header.append($checkall_box)

  $table = $('<table />')
  $table.append($checkbox_header).append($('<th>Customer Name</th>')).append($('<th>Emails</th>')).append($('<th>Phone Numbers</th>'))
  $table.addClass("table table-hover")
  if (search_string.length == 0) { 
    $('div#main-div').show()
    $('div#search-results').hide()
  }else{ 
    $('div#main-div').hide()
    $('div#search-results').html("")
    for(i = 0; i < global_data.length; ++i) {
      $main_row = $('<tr></tr>')
      
      $check_box_row = $('<td></td>')
      $checkbox = $('<input />')
      $checkbox.attr("type", "checkbox")
      $checkbox.attr("name", 'customer_ids[]')
      $checkbox.attr("value", global_data[i].id)
      $check_box_row.append($checkbox)
      
      $name_row = $('<td></td>')
      $name_link = $('<a />')
      $name_link.attr('href', "/customers/"+global_data[i].id)
      $name_link.html(global_data[i].name)
      $name_row.append($name_link)

      $email_row = $('<td></td>')
      $table_email = $('<table />')
      $table_email.addClass("table")

      for(j=0;j<global_data[i].emails.length;++j){
        $tr_email = $('<tr />')
        $td_email_type = $('<td />')
        $td_email_address = $('<td />') 
        $td_email_type.html(global_data[i].emails[j]['email_type'])
        $td_email_type.css("font-weight","bold")
        $td_email_address.html(global_data[i].emails[j]['address'])

        $tr_email.append($td_email_type).append($td_email_address)
        $table_email.append($tr_email)
      }
      $email_row.append($table_email)

      $phone_row = $('<td></td>')
      $table_phone = $('<table />')
      $table_phone.addClass("table")
      for(j=0;j<global_data[i].phone_numbers.length;++j){
        $tr_phone = $('<tr />')
        $td_phone_type = $('<td />')
        $td_phone = $('<td />') 
        $td_phone_type.html(global_data[i].phone_numbers[j]['phone_type'])
        $td_phone_type.css("font-weight","bold")
        $td_phone.html(global_data[i].phone_numbers[j]['phone'])

        $tr_phone.append($td_phone_type).append($td_phone)
        $table_phone.append($tr_phone)
      }
      $phone_row.append($table_phone)

      $main_row.append($check_box_row).append($name_row).append($email_row).append($phone_row)
      $table.append($main_row)
    }
    $submit = $('<input />')
    $submit.attr("type", "submit")
    $submit.addClass("export-csv")
    $submit.attr("value", "Export to CSV")

    $form.append($table).append($submit)
    $('div#search-results').append($form)
    $('div#search-results').show()
  }
}