package main

import (
	"cards-poc/internal/deck"
	"encoding/json"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws/session"
)

type RequestBody struct {
	User      string `json:"User"`
	CreatedAt int64  `json:"CreatedAt"`
	NCards    uint   `json:"NCards"`
}

type ResponseBody struct {
	Deck string `json:"Deck"`
}

var sess *session.Session

func init() {
	sess = session.Must(session.NewSessionWithOptions(session.Options{SharedConfigState: session.SharedConfigEnable}))
}

func createDeck(bodyReq RequestBody) (events.APIGatewayProxyResponse, error) {
	d := deck.NewCustomDeck(bodyReq.NCards)
	createdAt := time.Now().UnixMilli()
	newDeck := deck.UserDeck{
		User:           bodyReq.User,
		CreatedAt:      createdAt,
		UpdatedAt:      createdAt,
		OriginalLength: len(d),
		CurrentLenght:  len(d),
		Cards:          d,
	}
	record, err := deck.PutDeck(newDeck, sess)
	if err != nil {
		return events.APIGatewayProxyResponse{Body: err.Error(), StatusCode: 500}, nil
	}

	recordJson, err := json.Marshal(record)
	if err != nil {
		return events.APIGatewayProxyResponse{Body: err.Error(), StatusCode: 500}, nil
	}
	lambdaResponse := ResponseBody{Deck: string(recordJson)}

	return events.APIGatewayProxyResponse{Body: lambdaResponse.Deck, StatusCode: 200}, nil
}

func deleteDeck(bodyReq RequestBody) (events.APIGatewayProxyResponse, error) {
	err := deck.DeleteDeck(bodyReq.User, bodyReq.CreatedAt, sess)
	if err != nil {
		return events.APIGatewayProxyResponse{Body: "Deck not found", StatusCode: 404}, nil
	}
	return events.APIGatewayProxyResponse{Body: "", StatusCode: 200}, nil
}

func lambdaHandler(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	bodyReq := RequestBody{User: "", NCards: 52}
	httpMethod := request.HTTPMethod
	err := json.Unmarshal([]byte(request.Body), &bodyReq)
	if err != nil {
		return events.APIGatewayProxyResponse{Body: err.Error(), StatusCode: 404}, nil
	}
	switch httpMethod {
	case "POST":
		return createDeck(bodyReq)
	case "DELETE":
		return deleteDeck(bodyReq)
	default:
		return events.APIGatewayProxyResponse{Body: "Unsupported HTTP method: " + httpMethod, StatusCode: 412}, nil
	}
}

func main() {
	lambda.Start(lambdaHandler)
}
