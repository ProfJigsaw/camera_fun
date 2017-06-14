json.extract! image, :id, :filename, :content_type, :content, :created_at, :updated_at
json.url image_url(image, format: :json)
