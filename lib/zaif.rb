# coding: utf-8
require 'pp'
require 'json'
require 'openssl'
require 'uri'
require 'net/http'
require 'time'
require 'websocket-client-simple'

require_relative "./zaif/version"
require_relative "./zaif/exceptions"

module Zaif
    class API
        def initialize(opt = {})
            @cool_down = opt[:cool_down] || true
            @cool_down_time = opt[:cool_down_time] || 2
            @cert_path = opt[:cert_path] || nil
            @token = opt[:token] || nil
            @api_key = opt[:api_key] || nil
            @api_secret = opt[:api_secret] || nil
            @open_timeout = opt[:open_timeout] || 5
            @read_timeout = opt[:read_timeout] || 15
            @zaif_public_url = "https://api.zaif.jp/api/1/"
            @zaif_trade_url = "https://api.zaif.jp/tapi"
            @zaif_futures_public_url = "https://api.zaif.jp/fapi/1/"
            @zaif_leverage_trade_url = "https://api.zaif.jp/tlapi"
        end

        def set_api_key(api_key, api_secret)
            @api_key = api_key
            @api_secret = api_secret
        end

        def set_token(token)
            @token = token
        end

        #
        # Public API
        #

        # Get currencies.
        # @param [String]  currency_code  Base currency code
        def get_currencies(currency_code = "all")
            json = get_ssl(@zaif_public_url + "currencies/" + currency_code)
            return json
        end

        # Get currency_pairs.
        # @param [String]  currency_code          Base currency code
        # @param [String]  counter_currency_code  Counter currency code
        def get_currency_pairs(currency_code = "all", counter_currency_code = "jpy")
            if currency_code == "all"
                json = get_ssl(@zaif_public_url + "currency_pairs/" + currency_code)
            else
                json = get_ssl(@zaif_public_url + "currency_pairs/" + currency_code + "_" + counter_currency_code)
            end
            return json
        end

        # Get last price of *currency_code* / *counter_currency_code*.
        # @param [String]  currency_code          Base currency code
        # @param [String]  counter_currency_code  Counter currency code
        def get_last_price(currency_code, counter_currency_code = "jpy")
            json = get_ssl(@zaif_public_url + "last_price/" + currency_code + "_" + counter_currency_code)
            return json["last_price"]
        end

        # Get ticker of *currency_code* / *counter_currency_code*.
        # @param [String]  currency_code          Base currency code
        # @param [String]  counter_currency_code  Counter currency code
        def get_ticker(currency_code, counter_currency_code = "jpy")
            json = get_ssl(@zaif_public_url + "ticker/" + currency_code + "_" + counter_currency_code)
            return json
        end

        # Get trades of *currency_code* / *counter_currency_code*.
        # @param [String]  currency_code          Base currency code
        # @param [String]  counter_currency_code  Counter currency code
        def get_trades(currency_code, counter_currency_code = "jpy")
            json = get_ssl(@zaif_public_url + "trades/" + currency_code + "_" + counter_currency_code)
            # Convert to datetime
            json.each do |j|
                j["datetime"] = Time.at(j["date"].to_i)
            end
            return json
        end

        # Get depth of *currency_code* / *counter_currency_code*.
        # @param [String]  currency_code          Base currency code
        # @param [String]  counter_currency_code  Counter currency code
        def get_depth(currency_code, counter_currency_code = "jpy")
            json = get_ssl(@zaif_public_url + "depth/" + currency_code + "_" + counter_currency_code)
            return json
        end

        #
        # Trade API
        #

        # Get user infomation.
        # Need api key.
        # @return [Hash] Infomation of user.
        def get_info
            json = post_ssl(@zaif_trade_url, "get_info", {})
            # Convert to datetime
            json["datetime"] = Time.at(json["server_time"])
            return json
        end

        # Get lightweight user infomation.
        # Need api key.
        # @return [Hash] Infomation of user.
        def get_info2
            json = post_ssl(@zaif_trade_url, "get_info2", {})
            # Convert to datetime
            json["datetime"] = Time.at(json["server_time"])
            return json
        end

        # Get your trade history.
        # Avalible options: from. count, from_id, end_id, order, since, end, currency_pair
        # Need api key.
        # @param [Hash]
        def get_my_trades(option = {})
            json = post_ssl(@zaif_trade_url, "trade_history", option)
            # Convert to datetime
            json.each do|k, v|
                v["datetime"] = Time.at(v["timestamp"].to_i)
            end

            return json
        end

        # Get your active orders.
        # Avalible options: currency_pair
        # Need api key.
        def get_active_orders(option = {})
            json = post_ssl(@zaif_trade_url, "active_orders", option)
            # Convert to datetime
            json.each do|k, v|
                v["datetime"] = Time.at(v["timestamp"].to_i)
            end

            return json
        end

        # Issue trade.
        # Avalible options: limit, comment
        # Need api key.
        def trade(currency_code, price, amount, action, counter_currency_code = "jpy", option: {})
            currency_pair = currency_code + "_" + counter_currency_code
            option = option.merge({
                currency_pair: currency_pair,
                action: action,
                price: price,
                amount: amount,
            })
            json = post_ssl(@zaif_trade_url, "trade", option)
            return json
        end

        # Issue bid order.
        # Avalible options: limit, comment
        # Need api key.
        def bid(currency_code, price, amount, counter_currency_code = "jpy", option: {})
            return trade(currency_code, price, amount, "bid", counter_currency_code, option: option)
        end

        # Issue ask order.
        # Avalible options: limit, comment
        # Need api key.
        def ask(currency_code, price, amount, counter_currency_code = "jpy", option: {})
            return trade(currency_code, price, amount, "ask", counter_currency_code, option: option)
        end

        # Cancel order.
        # Need api key.
        def cancel(currency_code, order_id, counter_currency_code = "jpy")
            currency_pair = currency_code + "_" + counter_currency_code
            json = post_ssl(@zaif_trade_url, "cancel_order", {:order_id => order_id, :currency_pair => currency_pair})
            return json
        end

        # Withdraw funds.
        # Avalible options: opt_fee, message
        # Need api key.
        def withdraw(currency_code, address, amount, option = {})
            option["currency"] = currency_code
            option["address"] = address
            option["amount"] = amount
            json = post_ssl(@zaif_trade_url, "withdraw", option)
            return json
        end

        # Get your withdraw histories.
        # Avalible options: from, count, from_id, end_id, order, since, end
        # Need api key.
        def withdraw_history(currency, option = {})
            option["currency"] = currency
            json = post_ssl(@zaif_trade_url, "withdraw_history", option)
            # Convert to datetime
            json.each do|k, v|
                v["datetime"] = Time.at(v["timestamp"].to_i)
            end
            return json
        end

        # Get your deposit histories.
        # Avalible options: from, count, from_id, end_id, order, since, end
        # Need api key.
        def deposit_history(currency, option = {})
            option["currency"] = currency
            json = post_ssl(@zaif_trade_url, "deposit_history", option)
            # Convert to datetime
            json.each do|k, v|
                v["datetime"] = Time.at(v["timestamp"].to_i)
            end
            return json
        end

        #
        # Futures Public API
        #

        # Get last price of *currency_code* / *counter_currency_code*.
        # @param [String]  currency_code Base     currency code
        # @param [String]  counter_currency_code  Counter currency code
        def get_futures_last_price(group_id, currency_code = nil, counter_currency_code = "jpy")
            if ['all', 'active'].include?(group_id)
                json = get_ssl(@zaif_futures_public_url + "last_price/" + group_id)
                return json
            else
                json = get_ssl(@zaif_futures_public_url + "last_price/" + group_id + "/" + currency_code + "_" + counter_currency_code)
            end
            return json["last_price"]
        end

        # Get ticker of *currency_code* / *counter_currency_code*.
        # @param [String]  currency_code Base     currency code
        # @param [String]  counter_currency_code  Counter currency code
        def get_futures_ticker(group_id, currency_code, counter_currency_code = "jpy")
            json = get_ssl(@zaif_futures_public_url + "ticker/" + group_id + "/" + currency_code + "_" + counter_currency_code)
            return json
        end

        # Get trades of *currency_code* / *counter_currency_code*.
        # @param [String]  currency_code Base     currency code
        # @param [String]  counter_currency_code  Counter currency code
        def get_futures_trades(group_id, currency_code, counter_currency_code = "jpy")
            json = get_ssl(@zaif_futures_public_url + "trades/" + group_id + "/" + currency_code + "_" + counter_currency_code)
            return json
        end

        # Get depth of *currency_code* / *counter_currency_code*.
        # @param [String]  currency_code Base     currency code
        # @param [String]  counter_currency_code  Counter currency code
        def get_futures_depth(group_id, currency_code, counter_currency_code = "jpy")
            json = get_ssl(@zaif_futures_public_url + "depth/" + group_id + "/" + currency_code + "_" + counter_currency_code)
            return json
        end

        # Get groups of *group_id*
        # @param [String]  group_id Id of group
        def get_futures_groups(group_id = "all")
            json = get_ssl(@zaif_futures_public_url + "groups/" + group_id)
            return json
        end

        #
        # Leverage Trade API
        #

        # Get history of leverage trade.
        # Avalible options: from. count, from_id, end_id, order, since, end, currency_pair
        # Need api key.
        # @return [Hash] Infomation of positions
        def get_leverage_positions(type: "margin", group_id: nil, option: {})
            option["type"] = type
            option["group_id"] = group_id if group_id
            json = post_ssl(@zaif_leverage_trade_url, "get_positions", option)
            # Convert to datetime
            json.each do|k, v|
                v["datetime"] = Time.at(v["timestamp"].to_i)
                v["datetime_end"] = Time.at(v["term_end"].to_i)
                v["datetime_closed"] = Time.at(v["timestamp_closed"].to_i)
            end
            return json
        end

        # Get your details of leverage trade.
        # Avalible options: from. count, from_id, end_id, order, since, end, currency_pair
        # Need api key.
        # @param [Hash] Infomation of details
        def get_leverage_position_history(type, leverage_id, group_id = nil)
            option = {}
            option["type"] = type
            option["leverage_id"] = leverage_id
            unless group_id.nil?
                option["group_id"] = group_id
            end

            json = post_ssl(@zaif_leverage_trade_url, "position_history", option)
            # Convert to datetime
            json.each do|k, v|
                v["datetime"] = Time.at(v["timestamp"].to_i)
            end
            return json
        end

        # Get your active orders.
        # Avalible options: currency_pair
        # Need api key.
        # @return [Hash] Infomation of active positions
        def get_leverage_active_positions(type, group_id = nil, currency_pair = nil)
            option = {}
            option["type"] = type
            unless group_id.nil?
                option["group_id"] = group_id
            end
            unless currency_pair.nil?
                option["currency_pair"] = currency_pair
            end
            json = post_ssl(@zaif_leverage_trade_url, "active_positions", option)
            # Convert to datetime
            json.each do|k, v|
                v["datetime"] = Time.at(v["timestamp"].to_i)
                v["datetime_end"] = Time.at(v["term_end"].to_i)
            end
            return json
        end

        # Issue trade.
        # Need api key.
        def leverage_create_position(type, currency_code, price, amount, action, leverage,
          group_id = nil, limit = nil, stop = nil, counter_currency_code = "jpy")

            currency_pair = currency_code + "_" + counter_currency_code
            params = {:currency_pair => currency_pair, :action => action, :price => price,
               :amount => amount, :type => type, :leverage => leverage}

            params.store(:limit, limit) if limit
            params.store(:stop, stop) if stop
            params.store(:group_id, group_id) if group_id
            json = post_ssl(@zaif_leverage_trade_url, "create_position", params)
            # Convert to datetime
            json["datetime"] = Time.at(json["timestamp"].to_i)
            json["datetime_end"] = Time.at(json["term_end"].to_i)
            return json
        end

        # Change your position.
        # Need api key.
        def leverage_change_position(type, leverage_id, price, group_id = nil, limit = nil, stop = nil)
            params = {:type => type, :leverage_id => leverage_id, :price => price}
            params.store(:group_id, group_id) if group_id
            params.store(:limit, limit) if limit
            params.store(:stop, stop) if stop
            json = post_ssl(@zaif_leverage_trade_url, "change_position", params)
            # Convert to datetime
            json["datetime_closed"] = Time.at(json["timestamp_closed"].to_i)
            return json
        end

        # Cancel order.
        # Need api key.
        def leverage_cancel(type, leverage_id, group_id = nil)
            params = {:type => type, :leverage_id => leverage_id}
            params.store(:group_id, group_id) if group_id
            json = post_ssl(@zaif_leverage_trade_url, "cancel_position", params)
            # Convert to datetime
            json["datetime_closed"] = Time.at(json["timestamp_closed"].to_i)
            return json
        end

        #
        # Public stream api
        #

        def get_stream_info(currency_pair)
            url = "wss://ws.zaif.jp:8888/stream?currency_pair=" << currency_pair
            ws = WebSocket::Client::Simple.connect url

            Enumerator.new do |yielder|
                value = nil
                loop do
                    if value
                        yielder << value
                    end
                    ws.on :message do |msg|
                        value = JSON.parse(msg.data)
                    end
                end
            end.lazy
        end

        #
        # Class private method
        #

        private

        def check_key
            unless @token || (@api_key && @api_secret)
                raise "You need to set a API key and secret"
            end
        end

        # Connect to address via https, and return json reponse.
        def get_ssl(address)
            uri = URI.parse(address)
            begin
                https = Net::HTTP.new(uri.host, uri.port)
                https.use_ssl = true
                https.open_timeout = @open_timeout
                https.read_timeout = @read_timeout
                https.verify_mode = OpenSSL::SSL::VERIFY_PEER
                https.verify_depth = 5

                https.start {|w|
                    response = w.get(uri.request_uri)
                    case response
                    when Net::HTTPSuccess
                        json = JSON.parse(response.body)
                        raise JSONException, response.body if json == nil
                        raise APIErrorException, json["error"] if json.is_a?(Hash) && json.has_key?("error")
                        get_cool_down
                        return json
                    else
                        raise ConnectionFailedException, "Failed to connect to zaif."
                    end
                }
            rescue
                raise
            end
        end

        # Connect to address via https, and return json reponse.
        def post_ssl(address, method, data)
            check_key
            uri = URI.parse(address)
            data["method"] = method
            data["nonce"] = get_nonce
            begin
                req = Net::HTTP::Post.new(uri)
                req.set_form_data(data)

                if @token
                  req['token'] = @token
                else
                  req["Key"] = @api_key
                  req["Sign"] = OpenSSL::HMAC::hexdigest(OpenSSL::Digest.new('sha512'), @api_secret, req.body)
                end


                https = Net::HTTP.new(uri.host, uri.port)
                https.use_ssl = true
                https.open_timeout = @open_timeout
                https.read_timeout = @read_timeout
                https.verify_mode = OpenSSL::SSL::VERIFY_PEER
                https.verify_depth = 5

                https.start {|w|
                    response = w.request(req)
                    case response
                    when Net::HTTPSuccess
                        json = JSON.parse(response.body)
                        raise JSONException, response.body if json == nil
                        raise APIErrorException, json["error"] if json.is_a?(Hash) && json["success"] == 0
                        get_cool_down
                        return json["return"]
                    else
                        raise ConnectionFailedException, "Failed to connect to zaif: " + response.value
                    end
                }
            rescue
                raise
            end
        end

        def get_nonce
            time = Time.now.to_f
            return time
        end

        def get_cool_down
            if @cool_down
                sleep(@cool_down_time)
            end
        end

    end
end
