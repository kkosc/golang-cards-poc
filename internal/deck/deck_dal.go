package deck

import (
	"fmt"
	"log"
	"os"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
)

type UserDeck struct {
	User           string
	CreatedAt      int64
	UpdatedAt      int64
	OriginalLength int
	CurrentLenght  int
	Cards          Deck
}

func (ud *UserDeck) toString() string {
	return fmt.Sprintf("%s,%d,%s", ud.User, ud.CreatedAt, ud.Cards.ToString())
}

func ReadDeck(user string, createdAt int64, sess *session.Session) (*UserDeck, error) {
	ddb := dynamodb.New(sess)
	deckTableName := os.Getenv("DECKS_TABLE")

	ddbKey := map[string]*dynamodb.AttributeValue{"User": {S: aws.String(user)}, "CreatedAt": {N: aws.String(fmt.Sprint(createdAt))}}
	result, err := ddb.GetItem(&dynamodb.GetItemInput{TableName: aws.String(deckTableName), Key: ddbKey})
	if err != nil {
		log.Fatalf("Error when calling GetItem: %s", err)
		return nil, err
	}
	if result.Item == nil {
		log.Fatalf("Deck [%s, %d] not found!", user, createdAt)
		return nil, fmt.Errorf("Deck [%s, %d] not found!", user, createdAt)
	}
	record := UserDeck{}
	err = dynamodbattribute.UnmarshalMap(result.Item, &record)
	if err != nil {
		log.Fatalf("Error when unmarshalling item: %s", err)
		return nil, err
	}
	log.Printf("Successully read: " + record.toString() + " from table " + deckTableName)
	return &record, nil
}

func PutDeck(deck UserDeck, sess *session.Session) (*UserDeck, error) {
	deckTableName := os.Getenv("DECKS_TABLE")
	deck.UpdatedAt = time.Now().UnixMilli()
	ddb := dynamodb.New(sess)

	marshalledDeck, err := dynamodbattribute.MarshalMap(deck)
	if err != nil {
		log.Fatalf("Error when marshalling new item: %s", err)
		return nil, err
	}

	_, err = ddb.PutItem(&dynamodb.PutItemInput{TableName: &deckTableName, Item: marshalledDeck})
	if err != nil {
		log.Fatalf("Error when calling PutItem: %s", err)
		return nil, err
	}
	log.Printf("Successully added: " + deck.toString() + " to table " + deckTableName)
	return &deck, nil
}

func DeleteDeck(user string, createdAt int64, sess *session.Session) error {
	deckTableName := os.Getenv("DECKS_TABLE")
	ddb := dynamodb.New(sess)
	ddbKey := map[string]*dynamodb.AttributeValue{"User": {S: aws.String(user)}, "CreatedAt": {N: aws.String(fmt.Sprint(createdAt))}}
	_, err := ddb.DeleteItem(&dynamodb.DeleteItemInput{TableName: aws.String(deckTableName), Key: ddbKey})
	if err != nil {
		log.Fatalf("Error when deleting existing deck: %s", err)
		return err
	}
	return nil
}
