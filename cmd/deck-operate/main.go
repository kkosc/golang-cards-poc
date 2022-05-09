package main

import (
	"cards-poc/internal/deck"
	"encoding/json"
	"log"
	"strconv"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws/session"
)

type RequestInput struct {
	User      string `json:"User"`
	CreatedAt int64  `json:"CreatedAt"`
	N         int64  `json:"N"`
}

type ResponseBody struct {
	Deck string `json:"Deck"`
}

var sess *session.Session

func init() {
	sess = session.Must(session.NewSessionWithOptions(session.Options{SharedConfigState: session.SharedConfigEnable}))
}

func shuffleDeck(d deck.UserDeck) (events.APIGatewayProxyResponse, error) {
	d.UpdatedAt = time.Now().UnixMilli()
	d.Cards = d.Cards.Shuffle()

	record, err := deck.PutDeck(d, sess)
	if err != nil {
		return events.APIGatewayProxyResponse{Body: err.Error(), StatusCode: 500}, nil
	}

	return createResponse(record)
}

func dealFromDeck(d deck.UserDeck, nCards int) (events.APIGatewayProxyResponse, error) {
	dealtCards, err := d.Cards.Deal(nCards)
	if err != nil {
		return events.APIGatewayProxyResponse{Body: err.Error(), StatusCode: 412}, nil
	}
	d.UpdatedAt = time.Now().UnixMilli()
	d.CurrentLenght -= nCards

	_, err = deck.PutDeck(d, sess)
	if err != nil {
		return events.APIGatewayProxyResponse{Body: err.Error(), StatusCode: 500}, nil
		//we should re-insert the cards on error
	}

	return createResponse(dealtCards)
}

func createResponse(v any) (events.APIGatewayProxyResponse, error) {
	recordJson, err := json.Marshal(v)
	if err != nil {
		return events.APIGatewayProxyResponse{Body: err.Error(), StatusCode: 500}, nil
	}
	lambdaResponse := ResponseBody{Deck: string(recordJson)}

	return events.APIGatewayProxyResponse{Body: lambdaResponse.Deck, StatusCode: 200}, nil
}

func processRequest(request events.APIGatewayProxyRequest) (*RequestInput, error) {
	reqInput := RequestInput{User: "", CreatedAt: 0, N: 0}
	event, err := json.Marshal(request)
	if err != nil {
		return nil, err
	}
	log.Printf("Event: %s", event)
	switch request.HTTPMethod {
	case "GET":
		reqInput.User = request.QueryStringParameters["user"]                                  //Weird - parameter names are not transformed
		createdAt, err := strconv.ParseInt(request.QueryStringParameters["created-at"], 0, 64) //Weird - parameter names are not transformed
		if err != nil {
			return nil, err

		}
		reqInput.CreatedAt = createdAt
	default:
		err := json.Unmarshal([]byte(request.Body), &reqInput)
		if err != nil {
			return nil, err
		}
	}
	return &reqInput, nil
}

func lambdaHandler(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	reqInput, err := processRequest(request)
	if err != nil {
		return events.APIGatewayProxyResponse{Body: err.Error(), StatusCode: 412}, nil
	}

	d, err := deck.ReadDeck(reqInput.User, reqInput.CreatedAt, sess)
	if err != nil {
		return events.APIGatewayProxyResponse{Body: err.Error(), StatusCode: 404}, nil
	}

	switch request.Resource {
	case "/deck":
		return createResponse(d)
	case "/deck/shuffle":
		return shuffleDeck(*d)
	case "/deck/deal":
		return dealFromDeck(*d, int(reqInput.N))
	default:
		return events.APIGatewayProxyResponse{Body: "Unrecognized resource: " + request.Resource, StatusCode: 412}, nil
	}
}

func main() {
	lambda.Start(lambdaHandler)
}
