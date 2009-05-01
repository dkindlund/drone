module ClientsHelper
  def list_row_class(record)
    if record.is_a?(Client)
      return record.client_status.status
    end
  end
end
