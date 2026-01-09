class GraphqlController < ApplicationController
  # Disable CSRF protection for GraphQL endpoint (or use proper token auth)
  # skip_before_action :verify_authenticity_token, if: :json_request?
  
  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      current_user: nil, # Add user authentication here when needed
      current_time: Time.current,
      current_date: Date.current
    }
    
    result = HabitkitCloneSchema.execute(
      query,
      variables: variables,
      context: context,
      operation_name: operation_name
    )
    
    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?
    handle_error_in_development(e)
  end
  
  private
  
  def json_request?
    request.format.json?
  end
  
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash
    when nil
      {}
    else
      raise ArgumentError, "Unexpected variables: #{variables_param}"
    end
  end
  
  def handle_error_in_development(error)
    logger.error error.message
    logger.error error.backtrace.join("\n")
    
    render json: {
      errors: [
        {
          message: error.message,
          backtrace: error.backtrace
        }
      ],
      data: {}
    }, status: 500
  end
end
