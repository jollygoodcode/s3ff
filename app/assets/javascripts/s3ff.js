//= require s3_file_field
//= require jsrender.min

$(function() {

  // adapted from http://www.html5rocks.com/en/tutorials/cors/
  function iCanHasCORSRequest() {
    var xhr = new XMLHttpRequest();
    return (("withCredentials" in xhr) || (typeof XDomainRequest != "undefined"));
  }
  if (! iCanHasCORSRequest()) return;

  var ready = function() {
    var s3ff_init = function () {
      if ($(this).hasClass('s3ff_enabled')) return;

      var that = $(this).addClass('s3ff_enabled');
      var multi = that.attr('multiple');
      var label   = that.wrap($.templates($('#s3ff_label').html()).render()).parents('.s3ff_label').attr('for', that.attr('id'));
      var wrap = that.wrap('<div></div>').parent();
      var section = function(file, selector) {
        var upload = label.find("#upload-" + file.unique_id);
        return (selector ? upload.find(selector) : upload);
      };

      var s3ff_handlers = {
        change: function(e, data) {
          if (! multi) label.children('.s3ff_section').remove();
        },
        always: function(e, data) {
          wrap.parents("form").find("[type='submit']").each(function() {
            this.uploading = this.uploading || 0;
            $(this).attr({'disabled': (--this.uploading > 0)});
          });
        },
        add: function(e, data) {
          wrap.parents("form").find("[type='submit']").each(function() {
            this.uploading = this.uploading || 0;
            $(this).attr({'disabled': (++this.uploading > 0)});
          });
          data.submit();
        },
        send: function(e, data) {
          label.append($.templates($('#s3ff_upload').html()).render(data.files[0]));
        },
        done: function(e, data) {
          var upload = section(data.files[0]);
          var field_prefix = that.attr('name').replace(/\]$/, '');
          upload.append($.templates($('#s3ff_done').html()).render(data, { field_prefix: field_prefix }));
          upload.find('.s3ff_progress').hide();
        },
        fail: function(e, data) {
          section(data.files[0], '.s3ff_progress').html($.templates($('#s3ff_fail').html()).render(data));
        },
        progress: function(e, data) {
          var pct = (parseInt(data.loaded / data.total * 100, 10)) + "%";
          section(data.files[0], '.s3ff_progress .s3ff_bar').css({width: pct}).text(pct);
  }
      };

      var data = that.data('s3ff');
      if (data) {
        s3ff_handlers.send.apply(this, [null, data]);
        s3ff_handlers.done.apply(this, [null, data]);
      }

      that.S3FileField(s3ff_handlers);
    };

    var selector = "[data-acl][data-aws-access-key-id]:not(.s3ff_enabled)";
    $(selector).each(s3ff_init);
    $(document).on("mouseenter mousedown touchstart", selector, s3ff_init);
  };

  $(document).on('page:change', ready);
});
