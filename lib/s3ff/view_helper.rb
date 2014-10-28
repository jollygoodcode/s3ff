module S3FF
  module ViewHelper
    def include_s3ff_templates(map = { _direct_url: 'result.url' }) # extras: , _file_name: 'result.filename', _file_size: 'result.filesize', _content_type: 'result.filetype' })
      <<-EOM
      <div style="display:none;">
        <script id="s3ff_label" type="text/x-tmpl">
          <label class="s3ff_label" style="display:block;"></label>
        </script>
        <script id="s3ff_upload" type="text/x-tmpl" data-jsv-tmpl="_0">
          <div class="s3ff_section" id="upload-{{:unique_id}}" style="margin-top:1em;">
            <div class="progress s3ff_progress">
              <div class="progress-bar progress-bar-striped active s3ff_bar" style="width: 0%"></div>
            </div>
          </div>
        </script>
        <script id="s3ff_fail" type="text/x-tmpl">
          <div class="progress-bar progress-bar-danger" style="width: 80%">
            <span class="fa fa-exclamation-triangle"></span>
            {{if failReason}}
              {{:failReason}}
            {{else}}
              Upload failed!
            {{/if}}
          </div>
        </script>
        <script id="s3ff_done" type="text/x-tmpl">
          <button class="close" data-dismiss="alert" style="margin-right:4px;" type="button">
            <span aria-hidden="true">&times;</span><span class="sr-only">Close</span>
          </button>
          <span class="form-control">
            <span class="fa fa-file-o"></span>
            {{:result.filename}}
            {{if result.filesize}}
            ({{:result.filesize}} bytes)
            {{/if}}
          </span>
          <div style="display:none;">
            #{map.collect {|k,v| "<input name=\"{{>~field_prefix}}#{k}]\" type=\"hidden\" value=\"{{:#{v}}}\" />" }.join}
          </div>
        </script>
      </div>
      EOM
      .html_safe
    end
  end
end
