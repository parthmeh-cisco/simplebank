package gapi

import (
	"fmt"

	db "github.com/parthmeh-cisco/simplebank/db/sqlc"
	"github.com/parthmeh-cisco/simplebank/pb"
	"github.com/parthmeh-cisco/simplebank/token"
	"github.com/parthmeh-cisco/simplebank/util"
	"github.com/parthmeh-cisco/simplebank/worker"
)

// Server serves HTTP requests for our banking service.
type Server struct {
	pb.UnimplementedSimpleBankServer
	config          util.Config
	store           db.Store
	tokenMaker      token.Maker
	taskDistributor worker.TaskDistributor
}

// NewServer creates a new gRPC server.
func NewServer(config util.Config, store db.Store, taskDistributor worker.TaskDistributor) (*Server, error) {
	tokenMaker, err := token.NewPasetoMaker(config.TokenSymmetricKey)
	if err != nil {
		return nil, fmt.Errorf("cannot create token maker: %w", err)
	}

	server := &Server{
		config:          config,
		store:           store,
		tokenMaker:      tokenMaker,
		taskDistributor: taskDistributor,
	}

	return server, nil
}
