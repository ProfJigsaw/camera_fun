Camera
======

```
rails new camera_fun -d postgresql
cd camera_fun
```

### Gemfile

    gem 'slim-rails'

Run

    bundle update

### Images

    rails g scaffold Image filename:string content_type:string content:binary

### Routes

Edit `config/routes.rb`.

```ruby
  resources :images do
    member do
      get :inline
      post :update_image
    end
  end

  root 'images#index'
```

### Local database

    rails db:create db:migrate
    
### Controller

```ruby
  def inline
    image = Image.new(params.required(:id))
    send_data(send_data image.content, type: image.content_type, disposition: 'inline')
  end
  
  def update_image
    params.require(:imgBase64) =~ /^data:([^;]+);base64,(.*)$/
    content_type = $1
    content = Base64.decode64($2)
    image = Image.find(params[:id])
    image.update! content_type: content_type, content: content
    render plain: content.hash
  end
```

### View

`app/views/index.html.slim`:

```slim
h1 Camera Fun

table
  thead
    tr
      th ID
      th Created
      th Size

  tbody
    - @images.each do |image|
      tr valign="top"
        td = link_to image.id, image
        td = image.created_at.strftime('%F %R')
        td = image.content&.size
        - if image.content.present?
          td: img height=120 src="data:#{image.content_type};base64,#{Base64.strict_encode64(image.content)}"

br

= link_to 'New Image', images_path(image: {filename: 'Portrait'}), method: :post
```


`app/views/show.html.slim`:

```slim
- has_image = @image.persisted? && @image.content.present?

img#image.w-100.mb-3 src=(inline_image_path(@image) if has_image)

video#video.text-center.w-100 width="320" height="240" autoplay='autoplay' style=('display: none' if has_image)
canvas#canvas width="320" height="240" style='display: none'

.text-center.mb-3: button#snap.btn.btn-primary type="button" Ta bilde

javascript:
    // Grab elements, create settings, etc.
    var video = document.getElementById('video');

    // Get access to the camera!
    if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
        // Not adding `{ audio: true }` since we only want video now
        navigator.mediaDevices.getUserMedia({video: true}).then(function (stream) {
            video.src = window.URL.createObjectURL(stream);
            video.play();
        });
    }

    var canvas = document.getElementById('canvas');
    var context = canvas.getContext('2d');
    var video = document.getElementById('video');

    document.getElementById("snap").addEventListener("click", function () {
        context.drawImage(video, 0, 0, 320, 240);
        var dataUrl = canvas.toDataURL('image/png');
        $.ajax({
            type: "POST",
            url: "#{update_image_image_path}",
            data: { imgBase64: dataUrl }
        }).success(function (o) {
            console.log('saved: ' + o);
            $('#video').hide();
            $('#image').attr('src', "#{inline_image_path(@image)}?hash=" + o)
        });
    });
```

### Yarn

    brew install yarn
    yarn add jquery@2
    
### jQuery

Add to `app/assets/javascript/application.js` after `turbolinks`:

```javascript
//= require jquery
```

...and at the bottom:

```javascript
$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});
```

## Heroku

    heroku login

### Gemfile

At the end of Gemfile add:

```ruby
ruby "2.4.1"
```

### init

    heroku apps:create camera_fun
    heroku buildpacks:set heroku/ruby
    heroku buildpacks:add --index 1 heroku/nodejs
    git push heroku master
