module S3FF
  module ViewHelper
    def include_s3ff_templates
      <<-EOM
      <div style="display:none;">
        <script id="s3ff_template" type="text/x-tmpl">
          {^{if failReason}}
            <div class="progress s3ff_progress">
              <div class="progress-bar progress-bar-danger s3ff_bar" style="width:80%;">
                <span class="fa fa-exclamation-triangle"></span>
                {^{:failReason}}
              </div>
            </div>
          {^{else}}
            <div class="progress s3ff_progress" style="display:none;">
              <div class="progress-bar progress-bar-striped active s3ff_bar" style="width:0%;"></div>
            </div>
          {{/if}}
          {^{if result}}
            <div class="thumbnail" id="upload-{{:unique_id}}">
              <input type="hidden" data-link="name{:fieldname} value:{:result.url}"/>
              {^{if placeholder}}
                <img data-link="src{:result.url} alt{:result.filename}">
              {{/if}}
              <div class="caption">
                <button class="close" data-dismiss="alert" data-unique_id="{{:unique_id}}" data-target="#upload-{{:unique_id}}" style="margin-left:1em;" type="button">
                  <span aria-hidden="true">&times;</span><span class="sr-only">Remove</span>
                </button>
                <span class="fa fa-file-o"></span>
                {^{:result.filename}}
              </div>
            </div>
          {^{else}}
            {^{if placeholder}}
              <div class="thumbnail" id="upload-{{:unique_id}}">
                {^{if placeholder.url}}
                  <img data-link="src{:placeholder.url}">
                {{/if}}
                {^{if placeholder.filename}}
                  <div class="caption">
                    <span class="fa fa-file-o"></span>
                    {^{:placeholder.filename}}
                  </div>
                {{/if}}
              </div>
            {{/if}}
          {{/if}}
        </script>
      </div>
      EOM
      .html_safe
    end
  end
end
